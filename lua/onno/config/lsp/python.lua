local M = {}

M.attach = function(client, buffer)
  local sc = client.server_capabilities
  if client.name == "pylsp" then
    sc.documentFormattingProvider = false
    sc.documentRangeFormattingProvider = false
  end
  if client.name == "pyright" then
    client.server_capabilities.renameProvider = false -- rope is ok
    client.server_capabilities.hoverProvider = false -- pylsp includes also docstrings
    client.server_capabilities.signatureHelpProvider = false -- pyright typing of signature is weird
    client.server_capabilities.definitionProvider = false -- pyright does not follow imports correctly
    client.server_capabilities.referencesProvider = false -- pylsp does it
    client.server_capabilities.completionProvider = {
      resolveProvider = true,
      triggerCharacters = { "." },
    }
  end
end

return M
