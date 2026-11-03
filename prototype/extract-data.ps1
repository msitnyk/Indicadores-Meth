param([string]$SourceDirectory = (Split-Path -Parent $PSScriptRoot), [string]$OutputPath = (Join-Path $PSScriptRoot 'data-snapshot.json'), [switch]$Inspect)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$invariant = [System.Globalization.CultureInfo]::InvariantCulture
function Read-ZipXml($zip, [string]$name) {
    $entry = $zip.GetEntry($name)
    if ($null -eq $entry) { return $null }
    $reader = New-Object System.IO.StreamReader($entry.Open())
    try { return [xml]$reader.ReadToEnd() } finally { $reader.Dispose() }
}
function Get-Number([string]$text) {
    $number = 0.0
    if ([double]::TryParse($text, [System.Globalization.NumberStyles]::Float, $invariant, [ref]$number)) { return $number }
    return $null
}
function Read-Workbook([string]$path) {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($path)
    try {
        $strings = @()
        $sst = Read-ZipXml $zip 'xl/sharedStrings.xml'
        if ($sst) { $strings = @($sst.SelectNodes('//*[local-name()="si"]') | ForEach-Object { ($_.SelectNodes('.//*[local-name()="t"]') | ForEach-Object { $_.InnerText }) -join '' }) }
        $rels = Read-ZipXml $zip 'xl/_rels/workbook.xml.rels'
        $targets = @{}
        foreach ($rel in $rels.DocumentElement.ChildNodes) { $targets[$rel.Id] = $rel.Target }
        $workbook = Read-ZipXml $zip 'xl/workbook.xml'
        $sheets = @()
        foreach ($sheet in $workbook.SelectNodes('//*[local-name()="sheet"]')) {
            $rid = $sheet.GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
            $target = $targets[$rid]
            if ($target.StartsWith('/')) { $target = $target.TrimStart('/') } else { $target = 'xl/' + $target }
            $xml = Read-ZipXml $zip $target
            $f1 = $xml.SelectSingleNode('//*[local-name()="sheetData"]/*[local-name()="row"]/*[local-name()="c"][@r="F1"]/*[local-name()="v"]')
            $f1Cell = if ($f1) { $f1.ParentNode } else { $null }
            $f1Text = if ($f1 -and $f1Cell.t -eq 's') { $strings[[int]$f1.InnerText] } elseif ($f1) { $f1.InnerText } else { '' }
            # Do not scan huge legacy templates: they are not scoring sources.
            $readCells = $f1Text -eq 'Indicador' -or ([System.IO.Path]::GetFileName($path)).StartsWith('Retro') -or (([System.IO.Path]::GetFileName($path)).StartsWith('RIG') -and $sheet.name -eq 'Meth')
            $cells = @{}
            $dataCells = if ($readCells) { $xml.SelectNodes('//*[local-name()="sheetData"]/*[local-name()="row"]/*[local-name()="c"][*[local-name()="v"] or *[local-name()="is"]]') } else { @() }
            foreach ($cell in $dataCells) {
                $v = $cell.SelectSingleNode('./*[local-name()="v"]')
                $raw = if ($v) { $v.InnerText } else { '' }
                $text = $raw
                $value = $null
                if ($cell.t -eq 's' -and $raw -ne '') { $text = $strings[[int]$raw]; $value = $text }
                elseif ($cell.t -eq 'inlineStr') { $text = ($cell.SelectNodes('.//*[local-name()="t"]') | ForEach-Object { $_.InnerText }) -join ''; $value = $text }
                elseif ($cell.t -eq 'str' -or $cell.t -eq 'e') { $value = if ($raw -eq '') { $null } else { $raw } }
                elseif ($raw -ne '') { $value = Get-Number $raw; if ($null -eq $value) { $value = $raw } }
                if ($text -eq '') { $value = $null }
                $cells[$cell.r] = [pscustomobject]@{ text = [string]$text; raw = [string]$raw; value = $value; type = [string]$cell.t; style = [string]$cell.s }
            }
            # External hyperlink targets only; numeric issue IDs are never promoted to URLs.
            $hyperlinks = @{}
            $slash = $target.LastIndexOf('/')
            $sheetRels = Read-ZipXml $zip ($target.Substring(0, $slash) + '/_rels/' + $target.Substring($slash + 1) + '.rels')
            $sheetTargets = @{}
            if ($sheetRels) { foreach ($rel in $sheetRels.DocumentElement.ChildNodes) { if ($rel.TargetMode -eq 'External') { $sheetTargets[$rel.Id] = $rel.Target } } }
            foreach ($link in $xml.SelectNodes('//*[local-name()="hyperlink"]')) {
                $linkId = $link.GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
                if ($sheetTargets.ContainsKey($linkId)) { $hyperlinks[$link.ref] = $sheetTargets[$linkId] }
            }
            $sheets += [pscustomobject]@{ name = [string]$sheet.name; cells = $cells; hyperlinks = $hyperlinks }
        }
        $date1904 = $false
        $properties = $workbook.SelectSingleNode('//*[local-name()="workbookPr"]')
        if ($properties -and $properties.date1904 -in @('1', 'true')) { $date1904 = $true }
        return [pscustomobject]@{ file = [System.IO.Path]::GetFileName($path); sheets = $sheets; date1904 = $date1904 }
    } finally { $zip.Dispose() }
}
function Cell-Text($sheet, [string]$address) { if ($sheet.cells.ContainsKey($address)) { return $sheet.cells[$address].text }; return '' }
function Cell-Value($sheet, [string]$address) { if ($sheet.cells.ContainsKey($address)) { return $sheet.cells[$address].value }; return $null }
function Column-Number([string]$column) { $n = 0; foreach ($c in $column.ToUpperInvariant().ToCharArray()) { $n = $n * 26 + [int]$c - 64 }; return $n }
$books = @(Get-ChildItem -LiteralPath $SourceDirectory -Filter '*.xlsx' | Sort-Object Name | ForEach-Object { Read-Workbook $_.FullName })
if ($Inspect) {
    foreach ($book in $books) {
        Write-Output ('FILE: ' + $book.file)
        foreach ($sheet in $book.sheets) {
            Write-Output ('SHEET: ' + $sheet.name + ' F1=' + (Cell-Text $sheet 'F1'))
            if ($book.file.StartsWith('RIG') -and $sheet.name -eq 'Meth') { foreach ($address in ($sheet.cells.Keys | Sort-Object)) { if ($sheet.cells[$address].text -match '(?i)website|rig-website') { Write-Output ($address + '=' + $sheet.cells[$address].text) } } }
            if ((Cell-Text $sheet 'F1') -eq 'Indicador' -or $book.file.StartsWith('Retro')) {
                foreach ($row in 1..24) {
                    $line = @($sheet.cells.Keys | Where-Object { $_ -match ('^[A-Z]+' + $row + '$') } | Sort-Object { Column-Number ($_ -replace '\d','') } | ForEach-Object { if ($sheet.cells[$_].text -ne '') { $_ + '=' + $sheet.cells[$_].text } }) -join ' | '
                    Write-Output $line
                }
                Write-Output ('HYPERLINKS: ' + ($sheet.hyperlinks | ConvertTo-Json -Compress))
            }
        }
    }
    exit
}

# Calendar-month aggregation is provisional. Text headers do not establish a year.
$months = @(
    [pscustomobject]@{ id = '07'; label = 'Julio' },
    [pscustomobject]@{ id = '08'; label = 'Agosto' },
    [pscustomobject]@{ id = '09'; label = 'Septiembre' },
    [pscustomobject]@{ id = '10'; label = 'Octubre' },
    [pscustomobject]@{ id = '11'; label = 'Noviembre' }
)
$monthLookup = @{ julio = '07'; agosto = '08'; septiembre = '09'; sept = '09'; octubre = '10'; oct = '10'; noviembre = '11'; nov = '11' }
$warnings = New-Object 'System.Collections.Generic.List[object]'
function Warn([string]$kind, $projectId, [string]$message) {
    $warnings.Add([pscustomobject]@{ kind = $kind; projectId = $projectId; message = $message })
}
function Normalize-Text([string]$text) { return ($text -replace '\s+', ' ').Trim() }
function Excel-Date($book, $value) {
    $number = Get-Number ([string]$value)
    if ($null -eq $number) { return $null }
    if ($book.date1904) { $number += 1462 }
    return [datetime]::FromOADate($number)
}
function Project-Identity($book, $sheet) {
    if ($book.file.StartsWith('FedPat')) {
        if ($sheet.name.StartsWith('CRM')) { return @{ id = 'fedpat-crm'; account = 'FedPat'; name = 'CRM' } }
        if ($sheet.name.StartsWith('MARS')) { return @{ id = 'fedpat-mars'; account = 'FedPat'; name = 'MARS' } }
    }
    if ($book.file.StartsWith('CHUB')) { return @{ id = 'chub'; account = 'CHUB'; name = 'CHUB' } }
    if ($book.file.StartsWith('Fertisa')) { return @{ id = 'fertisa'; account = 'Fertisa'; name = 'Fertisa' } }
    if ($book.file.StartsWith('FluxIT')) { return @{ id = 'fluxit'; account = 'FluxIT'; name = 'FluxIT' } }
    if ($book.file.StartsWith('Medife')) { return @{ id = 'medife-portal'; account = 'Medifé'; name = 'Portal de prestadores' } }
    if ($book.file.StartsWith('RIG')) { return @{ id = 'rig-website'; account = 'RIG'; name = 'Website Redesign' } }
    if ($book.file.StartsWith('TecPlata')) { return @{ id = 'tecplata-l3'; account = 'TecPlata'; name = 'L3' } }
    if ($book.file.StartsWith('Tenpo')) { return @{ id = 'tenpo-migracion'; account = 'Tenpo'; name = 'Migración de Cuenta' } }
    throw ('Unmapped new-methodology source: ' + $book.file + ' / ' + $sheet.name)
}
$capacities = @()
$criteria = @()
$indicators = @()
$catalogById = @{}
$projects = @()
$projectSheets = @{}
foreach ($book in $books) {
    foreach ($sheet in $book.sheets) {
        # Selection criterion is content, never the sheet's name.
        if ((Cell-Text $sheet 'F1') -cne 'Indicador') { continue }
        $identity = Project-Identity $book $sheet
        $projectId = $identity.id
        $headers = @($sheet.cells.Keys | Where-Object { $_ -match '^[A-Z]+1$' } | Sort-Object { Column-Number ($_ -replace '\d','') })
        $maxColumn = $null
        $hintColumn = $null
        $periodSources = @()
        foreach ($address in $headers) {
            $column = $address -replace '\d', ''
            $header = Cell-Text $sheet $address
            $normalized = (Normalize-Text $header).ToLowerInvariant()
            if ($normalized -eq 'escala máxima') { $maxColumn = $column; continue }
            if ($normalized -eq 'hint') { $hintColumn = $column; continue }
            $month = $null
            $date = $null
            $yearConfirmed = $false
            if ($monthLookup.ContainsKey($normalized)) { $month = $monthLookup[$normalized] }
            else {
                $serial = Get-Number $header
                # Modern Excel dates in month-header positions; plain numeric indicator columns are excluded.
                if ($null -ne $serial -and $serial -ge 30000 -and $serial -le 60000 -and (Column-Number $column) -gt 8) {
                    $dt = Excel-Date $book $serial
                    $month = $dt.ToString('MM', $invariant)
                    $date = $dt.ToString('yyyy-MM-dd', $invariant)
                    $yearConfirmed = $true
                }
            }
            if ($null -ne $month) {
                if ($month -notin $months.id) { Warn 'period' $projectId ('Excluded unsupported month header ' + $column + ': ' + $header); continue }
                if ($month -in $periodSources.month) { throw ('Duplicate month ' + $month + ' in ' + $projectId) }
                $periodSources += [pscustomobject]@{ month = $month; column = $column; header = $header; date = $date; yearConfirmed = $yearConfirmed }
            }
        }
        if (-not $maxColumn -or -not $hintColumn) { throw ('Missing dynamic maximum/hint header in ' + $projectId) }
        if (@($periodSources | Where-Object { -not $_.yearConfirmed }).Count -gt 0) {
            Warn 'period' $projectId 'Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.'
        }
        if ($projectId -eq 'fedpat-mars') { Warn 'source' $projectId 'Se excluye la columna M (Jorge): no representa un mes y sus puntuaciones no se incorporan ni se usan como notas.' }
        if ($projectId -eq 'tecplata-l3') { Warn 'period' $projectId 'El encabezado K1 es el serial 46297.0, fecha 2026-10-02 (no 1 de octubre); se agrupa por mes calendario 10 preservando la fecha.' }
        $rows = @()
        foreach ($sourceRow in 2..24) {
            $idValue = Cell-Value $sheet ('E' + $sourceRow)
            $capValue = Cell-Value $sheet ('A' + $sourceRow)
            $maximum = Cell-Value $sheet ($maxColumn + $sourceRow)
            if ($idValue -isnot [double] -or $capValue -isnot [double] -or $maximum -isnot [double]) { throw ('Non-numeric identity/maximum in ' + $projectId + ' row ' + $sourceRow) }
            $id = [int]$idValue
            $capId = [int]$capValue
            $criterionId = Cell-Text $sheet ('C' + $sourceRow)
            $criterionNumber = Get-Number $criterionId
            if ($null -ne $criterionNumber) { $criterionId = $criterionNumber.ToString('0.0', $invariant) }
            if ($idValue -ne $id -or $capValue -ne $capId -or $capId -notin 1..3 -or $criterionId -notmatch ('^' + $capId + '\.[1-3]$') -or $maximum -le 0) { throw ('Invalid catalog identity in ' + $projectId + ' row ' + $sourceRow) }
            $name = Cell-Text $sheet ('F' + $sourceRow)
            $capName = Cell-Text $sheet ('B' + $sourceRow)
            $criterionName = Cell-Text $sheet ('D' + $sourceRow)
            $rubric = Cell-Text $sheet ('G' + $sourceRow)
            $hint = Cell-Text $sheet ($hintColumn + $sourceRow)
            if ($capId -notin $capacities.id) { $capacities += [pscustomobject]@{ id = $capId; name = $capName } }
            elseif ((Normalize-Text ($capacities | Where-Object id -eq $capId).name) -cne (Normalize-Text $capName)) { Warn 'source' $projectId ('Capacity name differs in row ' + $sourceRow + ': ' + $capName) }
            if ($criterionId -notin $criteria.id) { $criteria += [pscustomobject]@{ id = $criterionId; capId = $capId; name = $criterionName } }
            elseif ((Normalize-Text ($criteria | Where-Object id -eq $criterionId).name) -cne (Normalize-Text $criterionName)) { Warn 'source' $projectId ('Criterion name differs in row ' + $sourceRow + ': ' + $criterionName) }
            if (-not $catalogById.ContainsKey($id)) {
                $entry = [pscustomobject]@{ id = $id; criterionId = $criterionId; capId = $capId; name = $name; max = $maximum; rubric = $rubric; hint = $hint }
                $indicators += $entry
                $catalogById[$id] = $entry
            }
            else {
                $reference = $catalogById[$id]
                $differences = @()
                foreach ($property in @('name', 'rubric', 'hint')) {
                    $actual = switch ($property) { name { $name }; rubric { $rubric }; hint { $hint } }
                    if ((Normalize-Text $reference.$property) -cne (Normalize-Text $actual)) { $differences += $property }
                }
                if ($reference.max -ne $maximum) { $differences += 'max' }
                if ($reference.capId -ne $capId) { $differences += 'capId' }
                if ($reference.criterionId -ne $criterionId) { $differences += 'criterionId' }
                if ($differences.Count -gt 0) { Warn 'source' $projectId ('Catalog differs for indicator ' + $id + ' row ' + $sourceRow + ' (' + ($differences -join ', ') + '). Row identity, name and maximum preserved; rubric/hint catalog uses first source CHUB, source XLSX remains authoritative for variant text.') }
            }
            $values = [ordered]@{}
            foreach ($period in ($periodSources | Sort-Object month)) {
                $value = Cell-Value $sheet ($period.column + $sourceRow)
                $values[$period.month] = $value
                if ($value -is [double]) {
                    if ($value -lt 0 -or $value -gt $maximum) { Warn 'source' $projectId ('Out-of-range score at ' + $period.column + $sourceRow + ': ' + $value + ' / ' + $maximum + '. Preserved.') }
                } elseif ($null -ne $value -and $value -cne 'N/A') { Warn 'source' $projectId ('Unexpected non-numeric score at ' + $period.column + $sourceRow + ': ' + $value + '. Preserved.') }
            }
            $excludedColumns = @('A', 'B', 'C', 'D', 'E', 'F', 'G', $hintColumn, $maxColumn) + @($periodSources.column)
            if ($projectId -eq 'fedpat-mars') { $excludedColumns += 'M' }
            $notes = @()
            foreach ($address in @($sheet.cells.Keys | Where-Object { $_ -match ('^[A-Z]+' + $sourceRow + '$') } | Sort-Object { Column-Number ($_ -replace '\d','') })) {
                $column = $address -replace '\d', ''
                $text = Cell-Text $sheet $address
                if ($column -notin $excludedColumns -and $text -ne '') { $notes += [pscustomobject]@{ column = $column; text = $text } }
            }
            $rows += [pscustomobject]@{ id = $id; capId = $capId; criterionId = $criterionId; name = $name; max = $maximum; sourceRow = $sourceRow; values = [pscustomobject]$values; notes = $notes }
        }
        if (($rows.id | Sort-Object -Unique).Count -ne 23 -or @($rows | Where-Object { $_.id -notin 1..23 }).Count -gt 0) { throw ('Expected 23 unique indicators in ' + $projectId) }
        foreach ($period in $periodSources) {
            $monthId = $period.month
            if (@($rows | Where-Object { $null -ne $_.values.$monthId }).Count -eq 0) { Warn 'source' $projectId ('El mes ' + $monthId + ' tiene cabecera en ' + $period.column + ' pero los 23 valores están vacíos (null); no se arrastran datos de otro mes.') }
        }
        $projects += [pscustomobject]@{ id = $projectId; account = $identity.account; name = $identity.name; file = $book.file; sheet = $sheet.name; hasNew = $true; periodSources = $periodSources; rows = $rows }
        $projectSheets[$projectId] = $sheet
    }
}
# Requested roster for iteration 3: PNC/PC are excluded from the demo, not deleted from XLSX.
# New projects have no source or evaluation; never populate them with zero or synthetic scores.
foreach ($pending in @(@{ id = 'galicia'; name = 'Galicia' }, @{ id = 'santander'; name = 'Santander' }, @{ id = 'master-bapro'; name = 'Master Bapro' })) {
    $projects += [pscustomobject]@{ id = $pending.id; account = $pending.name; name = $pending.name; file = $null; sheet = $null; hasNew = $false; periodSources = @(); rows = @() }
    Warn 'source' $pending.id 'Proyecto incorporado por solicitud de METH, pendiente de evaluación. No se dispone de archivo fuente ni puntuaciones; no se imputa cero.'
}
# Evidence for the tentative website-redesign -> RIG mapping, never a scoring source.
$rigBook = $books | Where-Object { $_.file.StartsWith('RIG') }
$rigOld = $rigBook.sheets | Where-Object name -eq 'Meth'
$rigEvidence = @($rigOld.cells.GetEnumerator() | Where-Object { $_.Value.text -match '(?i)RIG\s*\|\s*Website Redesign|rig-website-redesign' } | Sort-Object Key | ForEach-Object { $_.Key + ': ' + $_.Value.text })
$rigSupported = $rigEvidence.Count -gt 0
$actions = @()
$actionBook = $books | Where-Object { $_.file.StartsWith('Retro METH') }
foreach ($sheet in $actionBook.sheets) {
    $headerColumns = @{}
    foreach ($address in $sheet.cells.Keys | Where-Object { $_ -match '^[A-Z]+1$' }) { $headerColumns[(Cell-Text $sheet $address)] = $address -replace '\d', '' }
    foreach ($required in @('#', 'Proyecto', 'Estado', 'Prioridad', 'Asunto', 'Fecha de inicio', 'Asignado a', 'Actualizado')) { if (-not $headerColumns.ContainsKey($required)) { throw ('Missing action header ' + $required) } }
    $sourceRows = @($sheet.cells.Keys | Where-Object { $_ -match ('^' + $headerColumns['#'] + '[2-9]\d*$|^' + $headerColumns['#'] + '1\d+$') } | ForEach-Object { [int]($_ -replace '[A-Z]', '') } | Sort-Object -Unique)
    foreach ($sourceRow in $sourceRows) {
        $idNumber = Cell-Value $sheet ($headerColumns['#'] + $sourceRow)
        if ($null -eq $idNumber) { continue }
        $id = ([double]$idNumber).ToString('0', $invariant)
        $sourceProject = Cell-Text $sheet ($headerColumns['Proyecto'] + $sourceRow)
        $projectId = $null
        if ($sourceProject -eq 'MARS - Gobernanza') { $projectId = 'fedpat-mars' }
        elseif ($sourceProject -eq 'Portal de Prestadores - Gobernanza') { $projectId = 'medife-portal' }
        elseif ($sourceProject -eq 'website-redesign-gobernanza' -and $rigSupported) { $projectId = 'rig-website' }
        $links = @()
        $proposals = @()
        switch ($id) {
            '39883' { $proposals = @(@{ indicatorId = 18; reason = 'El asunto explicita gestión de deuda técnica de repositorios, correspondiente al indicador 18; asociación MARS propuesta por nombre de proyecto, por confirmar.' }) }
            '39274' { $proposals = @(@{ indicatorId = 18; reason = 'El asunto explicita deuda técnica de infraestructura/configuración; METH nuevo Medifé fila 19 nota N describe cambios para igualar ambientes. Asociación propuesta, por confirmar.' }) }
            '39273' { $proposals = @(@{ indicatorId = 16; reason = 'Clasificar/cuantificar bugs podría operacionalizar la tasa de escape de defectos; Medifé fila 17 nota N menciona monitoreo relacionado con reingeniería. No prueba que todos los bugs sean escapes; propuesta por confirmar.' }) }
            '39272' { $proposals = @(@{ indicatorId = 17; reason = 'El asunto menciona DoD explícitamente, correspondiente a rigor del Definition of Done (fila 18). Relación propuesta, no confirmada.' }, @{ indicatorId = 10; reason = 'El asunto también menciona DoR; Medifé fila 11 (indicador 10) nota N dice Acordar y escribir el DOR. Relación adicional propuesta por evidencia de nota, por confirmar.' }) }
            '39271' { $proposals = @(@{ indicatorId = 8; reason = 'El asunto Obtener KPIs Nexo coincide con Medifé fila 9 nota N: Obtener KPIs de Nexo para empezar a priorizar el backlog en funcion a ellos. Asociación propuesta, por confirmar.' }) }
            '39270' { $proposals = @(@{ indicatorId = 12; reason = 'Mapa de dependencias coincide con gestión de dependencias y con Medifé fila 13 nota N (mismo action item de mapa de dependencias y acuerdo de DOR). Está Cancelled: conservar estado, no presentarla como acción activa. Propuesta por confirmar.' }) }
            '39779' { $proposals = @(@{ indicatorId = 22; reason = 'El asunto explicita clima/seguridad psicológica (indicador 22). Proyecto RIG sugerido por texto y enlace de hoja Meth antigua: RIG | Website Redesign y rig-website-redesign; no es confirmación de la relación.' }) }
            '39778' { $proposals = @(@{ indicatorId = 21; reason = 'Establecer retros formales corresponde a efectividad de las retrospectivas (21). Proyecto RIG sugerido por texto/enlace Website Redesign en Meth antiguo, por confirmar.' }) }
            '39777' { $proposals = @(@{ indicatorId = 2; reason = 'Última acción, fila 13: el asunto nombra Salud del backlog explícitamente y propone sumar BA en 2027. Relación sugerida, por confirmar.' }, @{ indicatorId = 3; reason = 'Última acción, fila 13: el asunto nombra Priorización por Impacto y ROI explícitamente. Relación sugerida, por confirmar.' }) }
        }
        if ($null -ne $projectId) { foreach ($proposal in $proposals) { $links += [pscustomobject]@{ projectId = $projectId; indicatorId = $proposal.indicatorId; confidence = 'suggested'; reason = $proposal.reason } } }
        else { Warn 'mapping' $null ('Acción ' + $id + ' / ' + $sourceProject + ': no hay proyecto inequívoco en los XLSX; projectId=null, links=[], sin asumir FluxIT.') }
        $url = $null
        foreach ($address in $sheet.cells.Keys | Where-Object { $_ -match ('^[A-Z]+' + $sourceRow + '$') }) {
            if ($sheet.hyperlinks.ContainsKey($address) -and $sheet.hyperlinks[$address] -match '^https?://') { $url = $sheet.hyperlinks[$address]; break }
            $text = Cell-Text $sheet $address
            if ($text -match '^https?://\S+$') { $url = $text; break }
        }
        $startDate = Excel-Date $actionBook (Cell-Value $sheet ($headerColumns['Fecha de inicio'] + $sourceRow))
        $updatedDate = Excel-Date $actionBook (Cell-Value $sheet ($headerColumns['Actualizado'] + $sourceRow))
        $start = if ($null -ne $startDate) { $startDate.ToString('yyyy-MM-dd', $invariant) } else { $null }
        $updated = if ($null -ne $updatedDate) { $rounded = $updatedDate.AddTicks(-($updatedDate.Ticks % [timespan]::TicksPerSecond)).AddSeconds([math]::Round($updatedDate.Millisecond / 1000.0)); $rounded.ToString('yyyy-MM-dd HH:mm', $invariant) } else { $null }
        $match = if ($null -ne $projectId) { 'suggested' } else { $null }
        $actions += [pscustomobject]@{
            id = $id; sourceProject = $sourceProject; status = (Cell-Text $sheet ($headerColumns['Estado'] + $sourceRow)); priority = (Cell-Text $sheet ($headerColumns['Prioridad'] + $sourceRow)); subject = (Cell-Text $sheet ($headerColumns['Asunto'] + $sourceRow)); owner = (Cell-Value $sheet ($headerColumns['Asignado a'] + $sourceRow)); start = $start; updated = $updated; file = $actionBook.file; sheet = $sheet.name; sourceRow = $sourceRow; url = $url; projectId = $projectId; projectMatch = $match; links = $links
        }
    }
}
Warn 'mapping' $null 'Todas las relaciones acción-proyecto e indicador son inferencias propuestas (suggested), por confirmar. website-redesign se sugiere para RIG por evidencia del Meth antiguo, sin usar sus puntajes.'
if (@($actions | Where-Object { $null -ne $_.url }).Count -eq 0) { Warn 'source' $null 'El XLSX de acciones no contiene URLs explícitas ni relaciones hyperlink externas: las 12 acciones conservan url=null. No se inventan enlaces Redmine a partir del ID.' }
if (@($projects | Where-Object hasNew).Count -ne 9) { throw 'Expected 9 new-methodology sources.' }
if (($projects.account | Sort-Object -Unique).Count -ne 11 -or $projects.Count -ne 12) { throw 'Expected 11 represented accounts and 12 projects, including three pending evaluations.' }
if ($actions.Count -ne 12) { throw ('Expected 12 actions, got ' + $actions.Count) }
if ($capacities.Count -ne 3 -or $criteria.Count -ne 8 -or $indicators.Count -ne 23) { throw 'Unexpected catalog size.' }
$snapshot = [ordered]@{ generatedAt = '2026-11-03'; months = $months; capacities = $capacities; criteria = $criteria; indicators = $indicators; projects = $projects; actions = $actions; warnings = @($warnings.ToArray()) }
$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory)) { New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null }
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutputPath, ($snapshot | ConvertTo-Json -Depth 20), $utf8)

# The report is regenerated along with the snapshot and documents the precise denominators.
$report = New-Object 'System.Collections.Generic.List[string]'
$report.Add('# Evidencia de extracción XLSX — iteración 3 · 2026-11-03')
$report.Add('')
$report.Add('Reproducir desde la raíz: `& .\prototype\extract-data.ps1`. Si la política de ejecución impide scripts, informar el bloqueo sin modificarla. PowerShell ZIP/XML y .NET, sin Python, módulos externos ni Excel instalado. Lee archivos en modo ZIP read-only. Salida UTF-8 sin BOM. Fecha de snapshot fijada por contrato; no es una fecha inferida de los datos.')
$report.Add('')
$report.Add('## Validaciones y cobertura')
$report.Add('')
$report.Add('- 8 cuentas con XLSX y 9 fuentes nuevas seleccionadas por F1=Indicador; 23 indicadores por fuente (207 filas). La demo representa 11 cuentas y 12 proyectos: nueve con METH nuevo y Galicia, Santander y Master Bapro pendientes, sin archivo ni puntuaciones. FedPat PNC/PC se excluyen por solicitud del usuario, sin modificar el XLSX. Catálogo: 3 capacidades, 8 criterios, 23 indicadores. Primera fuente CHUB define el catálogo; diferencias semánticas se advierten, no se normalizan silenciosamente.')
$report.Add('- 12 acciones (filas 2–13, incluida 39777); 0 URLs inventadas. Relaciones proposed/suggested, nunca confirmed. RR/Run Run quedan sin proyecto asociado.')
$report.Add('- values sólo contiene meses presentes en cabecera. Números reales (Double.Parse/TryParse InvariantCulture), N/A literal, vacío null; no forward-fill, no cero imputado. Columnas sin mes no entran en cálculos; M/Jorge de MARS se excluye íntegramente.')
$report.Add('- El agregado mensual es provisional por mes calendario, no un histórico interanual fiable: sólo RIG y TecPlata tienen año confirmado por fechas seriales. Los demás NO tienen año confirmado, incluso si el filename menciona un año.')
$report.Add('')
$report.Add('| Proyecto | Meses / columna / fecha confirmada | Numéricos | N/A | Vacíos | Cobertura numérica sobre celdas con mes |')
$report.Add('|---|---|---:|---:|---:|---:|')
$totalNumeric = 0; $totalNa = 0; $totalBlank = 0; $totalSlots = 0
foreach ($project in $projects) {
    $numeric = 0; $na = 0; $blank = 0
    foreach ($row in $project.rows) { foreach ($value in $row.values.psobject.Properties.Value) { if ($value -is [double]) { $numeric++ } elseif ($null -eq $value) { $blank++ } elseif ($value -eq 'N/A') { $na++ } } }
    $slots = $project.rows.Count * $project.periodSources.Count
    $totalNumeric += $numeric; $totalNa += $na; $totalBlank += $blank; $totalSlots += $slots
    $coverage = if ($slots) { (100.0 * $numeric / $slots).ToString('0.00', $invariant) + '%' } else { 'sin fuente' }
    $periodText = (@($project.periodSources | ForEach-Object { $_.month + '/' + $_.column + '/' + $(if ($_.yearConfirmed) { $_.date } else { 'año desconocido' }) }) -join '; ')
    if (-not $project.hasNew) { $periodText = 'sin METH NUEVO' }
    $report.Add('| ' + $project.account + ' · ' + $project.name + ' | ' + $periodText + ' | ' + $numeric + ' | ' + $na + ' | ' + $blank + ' | ' + $coverage + ' |')
}
$report.Add('')
$report.Add('Total de celdas con cabecera de mes: ' + $totalSlots + '; numéricas: ' + $totalNumeric + '; N/A: ' + $totalNa + '; vacías: ' + $totalBlank + '. Sobre universo fijo 9 fuentes × 23 indicadores × 5 meses = 1035 celdas, los meses sin columna representan ' + (1035 - $totalSlots) + ' celdas no disponibles, no valores null observados. Galicia, Santander y Master Bapro quedan fuera de este denominador por ausencia de fuente y evaluación.')
$report.Add('')
$report.Add('### Cobertura por mes calendario')
$report.Add('')
$report.Add('| Mes | Fuentes con cabecera | Fuentes con algún número | Numéricos | N/A | Vacíos observados | Celdas sin columna (de 207) |')
$report.Add('|---|---:|---:|---:|---:|---:|---:|')
foreach ($month in $months) {
    $monthId = $month.id
    $withColumn = @($projects | Where-Object { $monthId -in $_.periodSources.month })
    $withNumbers = 0; $numeric = 0; $na = 0; $blank = 0
    foreach ($project in $withColumn) {
        $projectNumeric = 0
        foreach ($row in $project.rows) {
            $value = $row.values.$monthId
            if ($value -is [double]) { $numeric++; $projectNumeric++ } elseif ($null -eq $value) { $blank++ } elseif ($value -eq 'N/A') { $na++ }
        }
        if ($projectNumeric -gt 0) { $withNumbers++ }
    }
    $report.Add('| ' + $month.label + ' (' + $monthId + ') | ' + $withColumn.Count + ' | ' + $withNumbers + ' | ' + $numeric + ' | ' + $na + ' | ' + $blank + ' | ' + (207 - $withColumn.Count * 23) + ' |')
}
$report.Add('')
$report.Add('## Septiembre: capacidad por proyecto y departamental')
$report.Add('')
$report.Add('Por proyecto/capacidad: 100 × promedio simple de (puntaje / máximo) de cada indicador numérico válido; cada indicador tiene el mismo peso. NO es suma de puntajes / suma de máximos. N/A, null y meses ausentes se excluyen, sin imputación. Cobertura: filas numéricas / total de indicadores de capacidad. Macro de proyecto: promedio simple de sus tres capacidades, sólo cuando las tres tienen datos válidos. Departamental por capacidad: promedio simple de porcentajes de proyectos válidos (peso igual proyecto; sin ausentes). Macro departamental: promedio simple de las macros de proyectos válidos. Los cálculos usan precisión completa; sólo la presentación se redondea.')
$report.Add('')
$report.Add('| Proyecto | C1 % (cobertura) | C2 % (cobertura) | C3 % (cobertura) | Macro % |')
$report.Add('|---|---:|---:|---:|---:|')
$capScores = @{ 1 = @(); 2 = @(); 3 = @() }
$projectMacroScores = @()
$septNumeric = 0; $septNa = 0; $septBlank = 0
foreach ($project in $projects) {
    $line = '| ' + $project.account + ' · ' + $project.name + ' |'
    $projectCapacityScores = @()
    foreach ($capacity in $capacities) {
        $all = @($project.rows | Where-Object capId -eq $capacity.id)
        $valid = @($all | Where-Object { $_.values.'09' -is [double] })
        $septNumeric += $valid.Count
        $septNa += @($all | Where-Object { $_.values.'09' -eq 'N/A' }).Count
        if ('09' -in $project.periodSources.month) { $septBlank += @($all | Where-Object { $null -eq $_.values.'09' }).Count }
        if ($valid.Count -gt 0) {
            $ratioSum = 0.0
            foreach ($row in $valid) { $ratioSum += $row.values.'09' / $row.max }
            $pct = 100.0 * $ratioSum / $valid.Count
            $capScores[$capacity.id] += $pct
            $projectCapacityScores += $pct
            $line += ' ' + $pct.ToString('0.00', $invariant) + '% (' + $valid.Count + '/' + $all.Count + ') |'
        } else { $line += ' sin datos |' }
    }
    if ($projectCapacityScores.Count -eq 3) {
        $macro = ($projectCapacityScores | Measure-Object -Average).Average
        $projectMacroScores += $macro
        $line += ' ' + $macro.ToString('0.00', $invariant) + '% |'
    } else { $line += ' sin datos |' }
    $report.Add($line)
}
$dept = '| **Departamental (peso igual proyecto válido)** |'
foreach ($capacity in $capacities) {
    $scores = $capScores[$capacity.id]
    $mean = ($scores | Measure-Object -Average).Average
    $dept += ' **' + $mean.ToString('0.00', $invariant) + '%** (' + $scores.Count + ' proyectos) |'
}
$macroMean = ($projectMacroScores | Measure-Object -Average).Average
$dept += ' **' + $macroMean.ToString('0.00', $invariant) + '%** (' + $projectMacroScores.Count + ' proyectos) |'
$report.Add($dept)
$report.Add('')
$report.Add('Septiembre: ' + $septNumeric + '/207 puntajes numéricos (' + (100.0 * $septNumeric / 207).ToString('0.00', $invariant) + '%), ' + $septNa + ' N/A y ' + $septBlank + ' vacíos. Año confirmado sólo en RIG y TecPlata. Los porcentajes son de madurez relativa al máximo aplicable, no promedios sobre escala fija 3.')
$report.Add('')
$report.Add('## Lista completa de acciones')
$report.Add('')
$report.Add('| ID / fila | Proyecto fuente → propuesta | Estado | Prioridad | Asunto | Responsable | Inicio | Actualizado (sin TZ) | Indicadores sugeridos | URL |')
$report.Add('|---|---|---|---|---|---|---|---|---|---|')
foreach ($action in $actions) {
    $target = if ($null -ne $action.projectId) { $action.projectId + ' (suggested)' } else { 'sin proyecto inequívoco' }
    $owner = if ($null -ne $action.owner) { $action.owner } else { 'sin asignar' }
    $urlText = if ($null -ne $action.url) { $action.url } else { 'null' }
    $report.Add('| ' + $action.id + ' / ' + $action.sourceRow + ' | ' + $action.sourceProject + ' → ' + $target + ' | ' + $action.status + ' | ' + $action.priority + ' | ' + ($action.subject -replace '\|', '\|') + ' | ' + $owner + ' | ' + $action.start + ' | ' + $action.updated + ' | ' + (($action.links.indicatorId) -join ', ') + ' | ' + $urlText + ' |')
}
$report.Add('')
$report.Add('### Evidencia de RIG (hoja antigua, sólo para sugerir proyecto)')
foreach ($evidence in $rigEvidence) { $report.Add('- ' + $evidence) }
$report.Add('')
$report.Add('## Anomalías y advertencias')
foreach ($warning in $warnings) { $report.Add('- [' + $warning.kind + '] ' + $(if ($null -ne $warning.projectId) { $warning.projectId + ': ' } else { '' }) + $warning.message) }
$report.Add('')
$report.Add('## Procedencia de archivos')
$report.Add('')
foreach ($file in Get-ChildItem -LiteralPath $SourceDirectory -Filter '*.xlsx' | Sort-Object Name) { $report.Add('- `' + $file.Name + '` SHA-256 `' + (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash + '`') }
$reportPath = Join-Path $outputDirectory 'extraction-report.md'
[System.IO.File]::WriteAllText($reportPath, ($report -join "`n") + "`n", $utf8)
Write-Output ('Extracted: ' + @($projects | Where-Object hasNew).Count + ' new sources, ' + $indicators.Count + ' indicators, ' + $actions.Count + ' actions. ' + $warnings.Count + ' warnings.')
Write-Output $OutputPath
Write-Output $reportPath
