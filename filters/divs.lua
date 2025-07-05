-- Function to clean text for LaTeX
local function clean_latex(s)
    if not s then return "" end
    s = s:gsub("\n", " "):gsub("\\", "\\textbackslash{}"):gsub("[{}]", "")
    return s
end

-- Function to convert SoftBreak to newlines in a Para block
local function para_to_yaml(para)
    local parts = {}
    for _, inline in ipairs(para.content) do
        if inline.t == "SoftBreak" then
            table.insert(parts, "\n")
        elseif inline.t == "Space" then
            table.insert(parts, " ")
        elseif inline.t == "Str" then
            table.insert(parts, inline.text)
        end
        -- Add more inline types if needed (e.g., Emph, Strong, etc.)
    end
    return table.concat(parts)
end

-- Function to parse simple YAML (key: value and lists with -)
function parse_yaml(text)
    local data = {}
    local current_key = nil
    for line in text:gmatch("[^\r\n]+") do
        -- Skip empty lines
        if line:match("^%s*$") then goto continue end
        -- List item (indented with -)
        local item = line:match("^%s*%-%s*(.+)$")
        if item and current_key then
            if type(data[current_key]) ~= "table" then
                data[current_key] = {}
            end
            table.insert(data[current_key], item)
        else
            -- Key: value
            local key, value = line:match("^%s*([%w_]+):%s*(.-)%s*$")
            if key and value then
                if value == "" then
                    data[key] = {}
                else
                    data[key] = value
                end
                current_key = key
            end
        end
        ::continue::
    end
    return data
end

-- Function to process a name/value string: bold the part before the first colon
local function process_namevalue(process_namevalue)
    local process_namevalue_cleaned = clean_latex(process_namevalue)
    -- Split at the first colon (if any)
    local colon_pos = process_namevalue_cleaned:find(":")
    if colon_pos then
        local before_colon = process_namevalue_cleaned:sub(1, colon_pos)
        local after_colon = process_namevalue_cleaned:sub(colon_pos + 1)
        -- Remove extra spaces after colon
        after_colon = after_colon:gsub("^%s*", "")
        return "\\textbf{" .. before_colon .. "} " .. after_colon
    else
        return process_namevalue_cleaned
    end
end

-- Adversaries filter
function Div(elem)
    if elem.classes:includes('adversary') then
        -- Extract the content as YAML text with newlines
        local yaml_text = ""
        for _, block in ipairs(elem.content) do
            if block.t == "Para" then
                yaml_text = yaml_text .. para_to_yaml(block) .. "\n"
            elseif block.t == "Plain" then
                -- If you have Plain blocks, handle them similarly
                yaml_text = yaml_text .. para_to_yaml({content = block.content}) .. "\n"
            end
        end

        -- Parse the YAML content to a Lua table
        local data = parse_yaml(yaml_text)
        if not data then return end

        -- Clean all main fields
        local name = clean_latex(data.name or "")
        local adv_type = clean_latex(data.type or "")
        local description = clean_latex(data.description or "")
        local tactics = clean_latex(data.tactics or "")
        local difficulty = clean_latex(data.difficulty or "")
        local thresholds = clean_latex(data.thresholds or "")
        local hp = clean_latex(data.hp or "")
        local stress = clean_latex(data.stress or "")
        local atk = clean_latex(data.atk or "")
        local experience = clean_latex(data.experience or "")

        -- Generate the weapons list
        local weapons = ""
        if data.weapons and #data.weapons > 0 then
            local weapon_list = {}
            for _, w in ipairs(data.weapons) do
                table.insert(weapon_list, process_namevalue(w))
            end
            weapons = table.concat(weapon_list, ", ")
        elseif data.weapon then
            weapons = process_namevalue(tostring(data.weapon))
        end

        -- Generate the features list
        local features_latex = ""
        if data.features then
            if type(data.features) == "table" then
                if #data.features > 0 then
                    features_latex = "\\eveleth\\fontsize{10pt}{10pt}\\selectfont\\MakeTextUppercase{Features}\n"
                    features_latex = features_latex .. "\\par\\smallskip\n"
                    features_latex = features_latex .. "\\normalfont\\fontsize{8pt}{8pt}\\selectfont\n"
                    features_latex = features_latex .. "\\begin{itemize}[leftmargin=0em, itemsep=3pt, parsep=4pt]\n"
                    features_latex = features_latex .. "\\renewcommand{\\labelitemi}{}\n"
                    for _, f in ipairs(data.features) do
                        features_latex = features_latex .. "\\item " .. process_namevalue(f) .. "\n"
                    end
                    features_latex = features_latex .. "\\end{itemize}\n"
                end
            else
                features_latex = "\\item " .. process_namevalue(data.features) .. "\n"
            end
        end

        -- Generate the main attributes block
        local adversaryinnerbox_latex = "\\textbf{Difficulty:} " .. difficulty .. " | " ..
            "\\textbf{Thresholds:} " .. thresholds .. " | " ..
            "\\textbf{HP:} " .. hp .. " | " ..
            "\\textbf{Stress:} " .. stress .. "\n\\par\\smallskip\n\n"

        adversaryinnerbox_latex = adversaryinnerbox_latex .. "\\textsc{ATK:} " .. atk .. " | " .. weapons .. "\n"

        if experience ~= "" then
            adversaryinnerbox_latex = adversaryinnerbox_latex ..
                "\\par\\smallskip \\myseparator \\par\\smallskip \\textbf{Experience}: " .. experience .. "\n"
        end

        -- Build the LaTeX command with cleaned arguments
        local latex = string.format(
            "\\adversary{%s}{%s}{%s}{%s}{%s}{%s}",
            name, adv_type, description, tactics, adversaryinnerbox_latex, features_latex
        )

        return pandoc.RawBlock("latex", latex)
    end
    if elem.classes:includes('environment') then
        -- Extract the content as YAML text with newlines
        local yaml_text = ""
        for _, block in ipairs(elem.content) do
            if block.t == "Para" then
                yaml_text = yaml_text .. para_to_yaml(block) .. "\n"
            elseif block.t == "Plain" then
                yaml_text = yaml_text .. para_to_yaml({content = block.content}) .. "\n"
            end
        end

        -- Parse the YAML content to a Lua table
        local data = parse_yaml(yaml_text)
        if not data then return end

        -- Clean all main fields
        local name = clean_latex(data.name or "")
        local env_type = clean_latex(data.type or "")
        local description = clean_latex(data.description or "")
        local impulses = clean_latex(data.impulses or "")
        local difficulty = clean_latex(data.difficulty or "")
        local adversaries = clean_latex(data.adversaries or "")

        -- Generate the features list
        local features_latex = ""
        if data.features then
            if type(data.features) == "table" then
                if #data.features > 0 then
                    features_latex = "\\eveleth\\fontsize{10pt}{10pt}\\selectfont\\MakeTextUppercase{Features}\n"
                    features_latex = features_latex .. "\\par\\smallskip\n"
                    features_latex = features_latex .. "\\normalfont\\fontsize{8pt}{8pt}\\selectfont\n"
                    features_latex = features_latex .. "\\begin{itemize}[leftmargin=0em, itemsep=3pt, parsep=4pt]\n"
                    features_latex = features_latex .. "\\renewcommand{\\labelitemi}{}\n"
                    for _, f in ipairs(data.features) do
                        features_latex = features_latex .. "\\item " .. process_namevalue(f) .. "\n"
                    end
                    features_latex = features_latex .. "\\end{itemize}\n"
                end
            else
                features_latex = "\\item " .. process_namevalue(data.features) .. "\n"
            end
        end

        -- Generate the main attributes block
        local environmentinnerbox_latex = "\\textbf{Difficulty:} " .. difficulty .. " | " ..
            "\\textbf{Potential adversaries:} " .. adversaries .. "\n\\par\\smallskip\n\n"

        -- Build the LaTeX command with cleaned arguments
        local latex = string.format(
            "\\environment{%s}{%s}{%s}{%s}{%s}{%s}",
            name, env_type, description, impulses, environmentinnerbox_latex, features_latex
        )

        return pandoc.RawBlock("latex", latex)
    end
end
