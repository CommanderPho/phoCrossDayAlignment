function data = fnCustomTifStackReader(filename)
    t = Tiff(filename,'r');
    offsets = getTag(t,'SubIFD');
    dirNum = 1; 
    setDirectory(t,dirNum);
    setSubDirectory(t,offsets(1));
    subimage_one = read(t);
    close(t);
end

