module.exports = (sizeInBytes) ->
  unities = ["B", "KB", "MB", "GB", "TB", "PB"]
  base = 1024
  out = sizeInBytes
  for unity, i in unities
    if out < base
      round = if unity is "B" then 0 else 2
      return "#{out.toFixed round} #{unity}"
    out = out / base
