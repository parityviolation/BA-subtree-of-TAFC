function closedaq()

hDaqController = evalin('base', 'hDaqController');
try hDaqDataViewer = evalin('base', 'hDaqDataViewer'); end
try hDaqPlotChooser = evalin('base', 'hDaqPlotChooser'); end
try hExptTable = evalin('base', 'hExptTable'); end

% If analysis plots are open then show them
h = guidata(hDaqDataViewer);
if getappdata(hDaqDataViewer,'frON')
    delete(h.fr.frFig)
end
if getappdata(hDaqDataViewer,'psthON')
    delete(h.psth.psthFig)
%     delete(h.psthTuningFig)
end
if getappdata(hDaqDataViewer,'lfpON')
    delete(h.lfp.lfpFig)
end

try delete(hDaqController); end
try delete(hDaqDataViewer); end
try delete(hDaqPlotChooser); end
try delete(hExptTable); end

evalin('base','clear hDaqController')
evalin('base','clear hDaqDataViewer')
evalin('base','clear hDaqPlotChooser')
evalin('base','clear hExptTable')

global AIOBJ DIOBJ
if isvalid(AIOBJ)
    delete(AIOBJ);
    clear AIOBJ
end
if isvalid(DIOBJ)
    delete(DIOBJ);
    clear DIOBJ
end