local function c(r, g, b, a)
    a = a or 255
    return {r / 255,  g / 255,  b / 255,  a / 255}
end

-- COLOR PALLETTES
-- Color palettes consist of 20 colors.
-- 1 - 16 are cell colors, 2 = 1, 4 = 2, 8 = 4 etc.
-- 17 should stand out, White or black is good. It's used for text and other important things
-- 18 is used for the background
-- 19 is used for stuff
-- 20 is used for special cells

return {
     -- DEFAULT
     c(135, 186, 226),
     {0.2, 0.28235294117647, 0.6078431372549, 1},
     {0.2, 0.29803921568627, 0.69411764705882, 1},
     {0.19607843137255, 0.31764705882353, 0.81176470588235, 1},
     {0.19607843137255, 0.46666666666667, 0.81176470588235, 1},
     {0.30196078431373, 0.61960784313725, 0.82352941176471, 1},
     {0.37254901960784, 0.68627450980392, 0.81176470588235, 1},
     {0.43137254901961, 0.79607843137255, 0.81176470588235, 1},
     {0.35294117647059, 0.85098039215686, 0.68627450980392, 1},
     {0.3843137254902, 0.92549019607843, 0.52941176470588, 1},
     {0.54509803921569, 0.95686274509804, 0.48627450980392, 1},
     {0.8, 0.98039215686275, 0.6078431372549, 1},
     {0.93725490196078, 0.98039215686275, 0.71372549019608, 1},
     {0.97254901960784, 0.83921568627451, 0.52549019607843, 1},
     {0.97254901960784, 0.66666666666667, 0.52549019607843, 1},
     {0.98039215686275, 0.43921568627451, 0.43921568627451, 1},
     c(217, 217, 217),
     c(65, 70, 92),
     {0.062745098039216, 0.086274509803922, 0.12156862745098, 1},
     c(254, 192, 71),

     -- Alt
    --  {0.37647058823529, 0.56470588235294, 0.84313725490196, 1},
    --  {0.33333333333333, 0.38823529411765, 0.87450980392157, 1},
    --  {0.48235294117647, 0.34509803921569, 0.92549019607843, 1},
    --  {0.59607843137255, 0.36862745098039, 0.96078431372549, 1},
    --  {0.67843137254902, 0.31372549019608, 0.98039215686275, 1},
    --  {0.85882352941176, 0.40392156862745, 0.9921568627451, 1},
    --  {0.96862745098039, 0.31764705882353, 0.90980392156863, 1},
    --  {0.96862745098039, 0.29411764705882, 0.81176470588235, 1},
    --  {0.96078431372549, 0.23529411764706, 0.71764705882353, 1},
    --  {0.94901960784314, 0.15686274509804, 0.58039215686275, 1},
    --  {0.97647058823529, 0.16078431372549, 0.45098039215686, 1},
    --  {0.97254901960784, 0.25098039215686, 0.39607843137255, 1},
    --  {0.97647058823529, 0.35686274509804, 0.35686274509804, 1},
    --  {0.97647058823529, 0.43921568627451, 0.35686274509804, 1},
    --  {0.95686274509804, 0.51764705882353, 0.35686274509804, 1},
    --  {0.93333333333333, 0.61176470588235, 0.37647058823529, 1},
    --  {0.89803921568627, 0.93333333333333, 0.9921568627451, 1},
    --  {0.2, 0.22352941176471, 0.36862745098039, 1},
    --  {0.058823529411765, 0.062745098039216, 0.11764705882353, 1},
    --  {0.27058823529412, 0.86666666666667, 0.28627450980392, 1},

    --  -- Even more alt
    --  {0.46274509803922, 0.20392156862745, 0.49411764705882, 1},
    --  {0.41176470588235, 0.20392156862745, 0.49411764705882, 1},
    --  {0.38039215686275, 0.20392156862745, 0.49411764705882, 1},
    --  {0.32549019607843, 0.20392156862745, 0.49411764705882, 1},
    --  {0.29019607843137, 0.20392156862745, 0.49411764705882, 1},
    --  {0.25098039215686, 0.20392156862745, 0.49411764705882, 1},
    --  {0.20392156862745, 0.22745098039216, 0.49411764705882, 1},
    --  {0.20392156862745, 0.27058823529412, 0.49411764705882, 1},
    --  {0.20392156862745, 0.30588235294118, 0.49411764705882, 1},
    --  {0.20392156862745, 0.34901960784314, 0.49411764705882, 1},
    --  {0.20392156862745, 0.3921568627451, 0.49411764705882, 1},
    --  {0.20392156862745, 0.44313725490196, 0.49411764705882, 1},
    --  {0.20392156862745, 0.47450980392157, 0.49411764705882, 1},
    --  {0.20392156862745, 0.49411764705882, 0.47058823529412, 1},
    --  {0.20392156862745, 0.49411764705882, 0.42352941176471, 1},
    --  {0.20392156862745, 0.49411764705882, 0.37254901960784, 1},
    --  {0.78039215686275, 0.82352941176471, 0.96470588235294, 1},
    --  {0.10196078431373, 0.050980392156863, 0.050980392156863, 1},
    --  {0.25882352941176, 0.11764705882353, 0.11764705882353, 1},
    --  {0.47058823529412, 0.75294117647059, 0.31372549019608, 1},
}