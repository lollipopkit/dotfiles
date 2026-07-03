local M = {}

function M.on_attach(client, bufnr)
    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
            silent = true,
            buffer = bufnr,
            desc = desc,
        })
    end

    -- 导航
    map("n", "gd", vim.lsp.buf.definition, "跳转到定义")
    map("n", "gD", vim.lsp.buf.declaration, "跳转到声明")
    map("n", "gr", vim.lsp.buf.references, "查找引用")
    map("n", "gi", vim.lsp.buf.implementation, "跳转到实现")
    map("n", "K", vim.lsp.buf.hover, "悬停信息")

    -- 编辑
    map("n", "<Leader>rn", vim.lsp.buf.rename, "重命名")
    map("n", "<Leader>ca", vim.lsp.buf.code_action, "代码操作")
    map("n", "<Leader>f", function()
        vim.lsp.buf.format({ async = true })
    end, "格式化")

    -- 诊断
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "上一个诊断")
    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "下一个诊断")
    map("n", "<Leader>d", vim.diagnostic.open_float, "显示诊断")
    map("n", "<Leader>dl", vim.diagnostic.setloclist, "诊断列表")

    if client.server_capabilities.inlayHintProvider then
        local inlay_hint = vim.lsp.inlay_hint
        if inlay_hint and type(inlay_hint.enable) == "function" then
            pcall(inlay_hint.enable, bufnr, true)
        elseif vim.lsp.buf and type(vim.lsp.buf.inlay_hint) == "function" then
            pcall(vim.lsp.buf.inlay_hint, bufnr, true)
        end
    end
end

function M.get_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp = pcall(require, "cmp_nvim_lsp")
    if ok then
        capabilities = cmp.default_capabilities(capabilities)
    end
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }
    return capabilities
end

function M.with_on_attach(extra)
    return function(client, bufnr)
        M.on_attach(client, bufnr)
        if extra then
            extra(client, bufnr)
        end
    end
end

return M
