function patternInfo=getPatternInfo(patterns, categName, cfg, varargin)
% This function analyses a set of rhythmic patterns that are given as input
% using grid representation (e.g. [111011101100]). 
% Different theoretical metrics are calculated, including syncopation scores and
% FFT analysis, separately for each pattern. 
% 
% -------
% INPUT
% -------
%     patterns:           1xM cell array, each cell contains a 1xN vector of ones and zeros, representing a pattern 
% 
% -------
% OUTPUT
% -------
%     patternInfo: 
% 


patternInfo = struct();

% go over all patterns (cells in the input array)
for pati=1:length(patterns)
    
    % save the pattern in the structure
    patternInfo(pati).pattern = patterns{pati}; 
    
    % get its IOI ratios and save them for completeness
    patternInfo(pati).ioiRatios = diff(find([patterns{pati},1])); 
    
    % allocate variables for this pattern
    PE3 = zeros(1,length(patterns{pati}));     
    PE4 = zeros(1,length(patterns{pati}));     

    LHL24 = zeros(1,length(patterns{pati}));     
    LHL26 = zeros(1,length(patterns{pati})); 
    LHL36 = zeros(1,length(patterns{pati})); 
    
    shiftedPattern = cell(1,length(patterns{pati})); 
    
    % Go over all phases ("shift" the starting point of the pattern by 1 event at a time)
    % If the pattern would be presented as seamlessly cycled over a long
    % period of time, we don't know what meter phase would be perceived.
    % This looks at all different meter-phase possibilities. 
    for phasei=0:length(patterns{pati})-1
        
        % get the shifted pattern 
        shiftedPattern{phasei+1} = circshift(patterns{pati},phasei); 
        
        % get 4 cycles of the pattern to be input for syncopation score
        % analyses 
        pat2use4syncop = repmat(shiftedPattern{phasei+1},1,4); 
        
        %=================================================================
        % calculate Povel&Essens (PE) syncopation score (C-score) for the
        % phase-shifted pattern assuming pulse starts with the first 
        % event in the shifted pattern
        
        % assume pulse with period 3 events
        PE3(phasei+1) = syncopationPE(pat2use4syncop, 3); 
        
        % assume pulse with period 4 events
        PE4(phasei+1) = syncopationPE(pat2use4syncop, 4); 

        %=================================================================
        % get Longuet-Higgins&Lee (LHL) syncopation score for the
        % phase-shifted pattern, assuming that the metric template starts
        % with the frist event in the shifted pattern
        
        % assume nested pulses with periods 2 and 4 grid events 
        LHL24_percycle = syncopationLHL(pat2use4syncop,'2_4', length(patterns{pati}), 'perbar'); 
        % get the sycnopation-score for the second cycle (this way we don't
        % assume that there is 'nothing' before the pattern, but we
        % calculate something similar to a circular measure, assuming that
        % the pattern is periodic)
        LHL24(phasei+1) = LHL24_percycle(2); 

        % assume nested pulses with periods 2 and 6 grid events 
        LHL26_percycle = syncopationLHL(pat2use4syncop,'2_6', length(patterns{pati}), 'perbar'); 
        LHL26(phasei+1) = LHL26_percycle(2); 
        
        % assume nested pulses with periods 3 and 6 grid events 
        LHL36_percycle = syncopationLHL(pat2use4syncop,'3_6', length(patterns{pati}), 'perbar'); 
        LHL36(phasei+1) = LHL36_percycle(2); 
    end
    
    % give the pattern an ID number in the resutling structure
    patternInfo(pati).ID = sprintf('%s%d',categName,pati); 
    % save the number of sound events in the pattern
    patternInfo(pati).n_sounds = sum(shiftedPattern{1}); 
    % save total number of events in the pattern
    patternInfo(pati).n_events = length(shiftedPattern{1}); 
    
    % PE summary statistics
    patternInfo(pati).PE3 = PE3; 
    patternInfo(pati).PE4 = PE4; 
    patternInfo(pati).rangePE3 = max(PE3)-min(PE3); 
    patternInfo(pati).rangePE4 = max(PE4)-min(PE4); 
    patternInfo(pati).minPE3 = min(PE3); 
    patternInfo(pati).minPE4 = min(PE4); 
    
    % LHL summary statistics
    patternInfo(pati).LHL24 = LHL24; 
    patternInfo(pati).LHL26 = LHL26; 
    patternInfo(pati).LHL36 = LHL36; 
    patternInfo(pati).rangeLHL24 = max(LHL24)-min(LHL24); 
    patternInfo(pati).rangeLHL26 = max(LHL26)-min(LHL26); 
    patternInfo(pati).rangeLHL36 = max(LHL36)-min(LHL36); 
    patternInfo(pati).minLHL24 = min(LHL24); 
    patternInfo(pati).minLHL26 = min(LHL26); 
    patternInfo(pati).minLHL36 = min(LHL36); 
    
end


