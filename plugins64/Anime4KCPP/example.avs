LoadPlugin("./dll/Anime4KCPP_AviSynthPlus.dll")

#list your platform ID and device ID, This function will throw an error which contians GPU infomation
#列出支持的platform ID和device ID, 该函数会抛出一个错误, 以显示GPU信息
listGPUs()

#Anime4KCPP()
#parameters: description (type [=default])
#passes: Passes for processing (int [=2])
#pushColorCount: Limit the number of color pushes, make sure the edge won't be too thin (int [=2])
#strengthColor:  Strength for pushing color,range 0 to 1,higher for thinner (double [=0.3])
#strengthGradient: Strength for pushing gradient,range 0 to 1,higher for sharper (double [=1])
#zoomFactor: upscaling ratio for resizing (double [=1])
#ACNet: Enable ACNet (bool [=false])
#GPUMode: Enable GPU acceleration (bool [=false])
#HDN: Enable HDN mode for ACNet (bool [=false])
#platformID, deviceID: For specifying the GPU (int [=0])

#Anime4KCPP supports RGB24 and YUV 8bit(ACNet support YUV444,422,420, Anime4K09 support YUV444) input
#Anime4KCPP支持RGB24和YUV(ACNet支持YUV444, 422, 420, Anime4K09支持YUV444)输入
FFVideoSource("G:\anime4k\P1-1.m4v").Anime4KCPP(GPUMode=true,zoomFactor=2,ACNet=true,HDN=true)