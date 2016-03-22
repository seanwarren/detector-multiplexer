% workaround for this bug: https://www.mathworks.com/support/bugreports/1293244
if ispc;
    javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
else ismac;
    javax.swing.UIManager.setLookAndFeel('com.apple.laf.AquaLookAndFeel');
end

mux_ui