--- get stat information on a path
-- @param path to stat
-- @param the ftype to return
-- @return false if ftype or path does not exist
function file_info(path, ftype)
	local attr = lighty.stat(path)
	if attr and attr[ftype] then
		return attr[ftype]
	end
	return false
end

--- Wrapper for reading a full file into a string
-- @param filename Full path to the file
-- @return a string with the content of the file
function read_file(filename)
	local content = ""
	if file_info(filename, "is_file") then
		local file = io.open(filename, "r")
		content = file:read("*a")
		io.close(file)
	end
	return content
end

--- Concat multiple files into one file
-- @param lighty lighty global variable passed to the method
-- @param match The files that will be concat into a file
-- @param fileExtension Do !NOT! include the dot ( . )
function etfile(lighty)
	require "md5"
	local hash = md5.sumhexa(read_file(lighty.env["physical.path"]))
	lighty.header["Etag"] = '"' .. hash ..'"'
end

if (file_info(lighty.env["physical.path"], "is_file")) then
	if string.match(lighty.env["physical.path"], "MinecraftDownload/.*") then
		return etfile(lighty)
	end
end
