--local ffi   = require( "ffi" )
--local gl    = require( "gl" )
--require "BanateCore"

local function checkGL( str )
	local r = gl.glGetError()

	str = str or""
	local err = string.format("%s  OpenGL Error: 0x%x", str, tonumber(r))

	assert( r == 0, err)
end


class.GLTexture()

GLTexture.Defaults = {
	UnpackAlignment = 1,
}



function GLTexture:_init(width, height, gpuFormat, data, dataFormat, datatype, bytesPerElement)
--print("GLTexture:_init")

	self.Width = width
	self.Height = height

	-- Get a texture ID for this texture
	local tid = ffi.new( "GLuint[1]" )
	gl.glGenTextures( 1, tid )
	self.TextureID = tid[0]
	checkGL( "glBenTextures" )

	-- Enable Texture Mapping
	glEnable(GL_TEXTURE_2D)

	-- Bind to the texture so opengl knows which Texture object
	-- we are operating on
	gl.glBindTexture( GL_TEXTURE_2D, self.TextureID )
	checkGL( "glBindTexture")


	-- Text filtering must be established
	-- if you just see white on the texture, then chances
	-- are the filters have not been setup

	-- Create Nearest Filtered Texture
	gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
	checkGL("minfilter")
	gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
	checkGL("magfilter")



--print("GLTexture:_init()")
--print(string.format("  incoming: 0x%x", incoming))
--print("Size: ", self.Width, self.Height)

	gl.glPixelStorei(GL_UNPACK_ALIGNMENT, GLTexture.Defaults.UnpackAlignment)
	gl.glTexImage2D (GL_TEXTURE_2D,
		0, 				-- texture level
		gpuFormat, 	-- internal format
		self.Width, 	-- width
		self.Height, 	-- height
		0, 				-- border
		dataFormat, 		-- format of incoming data
		datatype,	-- data type of incoming data
		data)		-- pointer to incoming data, if any

	checkGL("glTexImage2D")

	-- Disable Texture Mapping
	glDisable(GL_TEXTURE_2D)
end

function GLTexture:SetFilters(minFilter, magFilter)
	gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter)
	checkGL("minfilter")
	gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter)
	checkGL("magfilter")
end


function GLTexture.MakeCurrent(self)
--print("Texture.MakeCurrent() - ID: ", self.TextureID);
	gl.glBindTexture(GL_TEXTURE_2D, self.TextureID)
	checkGL("glBindTexture")
end


function GLTexture:CopyPixelData(width, height, data, dataFormat, datatype)
	datatype = datatype or GL_UNSIGNED_BYTE

--print("Texture.CopyPixelBuffer: Width/Height: ", width, height)
--print("Data: ", data);
--print(string.format("format: 0x%x  type: 0x%x", dataFormat, datatype))

	glEnable(GL_TEXTURE_2D)            -- Enable Texture Mapping
	self:MakeCurrent()

	gl.glPixelStorei(GL_UNPACK_ALIGNMENT,  2)
	checkGL("glPixelStorei")

	gl.glTexSubImage2D (GL_TEXTURE_2D,
		0,	-- level
		0, 	-- xoffset
		0, 	-- yoffset
		width, 	-- width
		height, -- height
		dataFormat,		-- format of incoming data
		datatype,	-- data type of incoming data
		data)		-- pointer to incoming data
	checkGL("glTexSubImage2D")
end


function GLTexture.CopyPixelBuffer(self, pixelaccessor)
	local incoming = GL_BGRA
	if pixelaccessor.BitsPerElement == 24 then
		incoming = GL_BGR
	end

--print(string.format("  incoming: 0x%x", incoming))
--print("Texture.CopyPixelBuffer: Width/Height: ", pixbuff.Width, pixbuff.Height)
--print("Pixels: ", pixbuff.Pixels)
--print("Texture:CopyPixelBuffer BitesPerElement: ", pixbuff.BitsPerElement)

	gl.glEnable(GL_TEXTURE_2D)            -- Enable Texture Mapping
	self:MakeCurrent()

	gl.glPixelStorei(GL_UNPACK_ALIGNMENT,  Texture.Defaults.UnpackAlignment)

	gl.glTexSubImage2D (GL_TEXTURE_2D,
		0,	-- level
		0, 	-- xoffset
		0, 	-- yoffset
		pixelaccessor.Width, 	-- width
		pixelaccessor.Height, -- height
		incoming,		-- format of incoming data
		GL_UNSIGNED_BYTE,	-- data type of incoming data
		pixelaccessor.Data)		-- pointer to incoming data
end

function GLTexture.Render(self, x, y, awidth, aheight)
	x = x or 0
	y = y or 0
	awidth = awidth or self.Width
	aheight = aheight or self.Height

	--print("Textue:Render - x,y, width, height", x, y, awidth, aheight)

	--gl.glPixelStorei(GL_UNPACK_ALIGNMENT, 1)

	glEnable(GL_TEXTURE_2D)

	self:MakeCurrent()


	glBegin(GL_QUADS)
		--gl.glNormal3d( 0, 0, 1)                      -- Normal Pointing Towards Viewer

		gl.glTexCoord2f(0, 0)
		gl.glVertex3f(x, y+aheight,  0)  -- Point 1 (Front)



		gl.glTexCoord2f(1, 0)
		gl.glVertex3f( x+awidth, y+aheight,  0)  -- Point 2 (Front)


		gl.glTexCoord2f(1, 1)
		gl.glVertex3f( x+awidth,  y,  0)  -- Point 3 (Front)

		gl.glTexCoord2f(0, 1)
		gl.glVertex3f(x,  y,  0)  -- Point 4 (Front)
	glEnd()

	-- Disable Texture Mapping
	glDisable(GL_TEXTURE_2D)
end



function GLTexture.Create(width, height, gpuFormat, data, dataFormat, datatype, bytesPerElement)
	gpuFormat = gpuFormat or GL_RGB
	data = data or nil
	dataFormat = dataFormat or GL_RGB
	datatype = datatype or GL_UNSIGNED_BYTE
	bytesPerElement = bytesPerElement or 3

	return GLTexture(width, height, gpuFormat, data, dataFormat, datatype, bytesPerElement)
end

function GLTexture.CreateFromAccessor(pixelaccessor)
	local dataFormat = GL_BGRA
	if pixelaccessor.BitsPerElement == 24 then
		dataFormat = GL_BGR
	end

	return GLTexture(pixelaccessor.Width, pixelaccessor.Height, GL_RGB,
		pixelaccessor.Data, dataFormat, pixelaccessor.BytesPerElement)
end
