addpath /home/common/matlab/fieldtrip
ft_defaults

bidsroot = '/cephfs/data/DSC_3011020.09_236:v1/';

subA = {'sub-A2002' 'sub-A2003' 'sub-A2004' 'sub-A2005' 'sub-A2006' 'sub-A2007' 'sub-A2008' 'sub-A2009' 'sub-A2010' 'sub-A2011' 'sub-A2013' 'sub-A2014' 'sub-A2015' 'sub-A2016' 'sub-A2017' 'sub-A2019' 'sub-A2020' 'sub-A2021' 'sub-A2024' 'sub-A2025' 'sub-A2027' 'sub-A2028' 'sub-A2029' 'sub-A2030' 'sub-A2031' 'sub-A2032' 'sub-A2033' 'sub-A2034' 'sub-A2035' 'sub-A2036' 'sub-A2037' 'sub-A2038' 'sub-A2039' 'sub-A2040' 'sub-A2041' 'sub-A2042' 'sub-A2046' 'sub-A2047' 'sub-A2049' 'sub-A2050' 'sub-A2051' 'sub-A2052' 'sub-A2053' 'sub-A2055' 'sub-A2056' 'sub-A2057' 'sub-A2058' 'sub-A2059' 'sub-A2061' 'sub-A2062' 'sub-A2063' 'sub-A2064' 'sub-A2065' 'sub-A2066' 'sub-A2067' 'sub-A2068' 'sub-A2069' 'sub-A2070' 'sub-A2071' 'sub-A2072' 'sub-A2073' 'sub-A2075' 'sub-A2076' 'sub-A2077' 'sub-A2078' 'sub-A2079' 'sub-A2080' 'sub-A2083' 'sub-A2084' 'sub-A2085' 'sub-A2086' 'sub-A2088' 'sub-A2089' 'sub-A2090' 'sub-A2091' 'sub-A2092' 'sub-A2094' 'sub-A2095' 'sub-A2096' 'sub-A2097' 'sub-A2098' 'sub-A2099' 'sub-A2101' 'sub-A2102' 'sub-A2103' 'sub-A2104' 'sub-A2105' 'sub-A2106' 'sub-A2108' 'sub-A2109' 'sub-A2110' 'sub-A2111' 'sub-A2113' 'sub-A2114' 'sub-A2116' 'sub-A2117' 'sub-A2119' 'sub-A2120' 'sub-A2121' 'sub-A2122' 'sub-A2124' 'sub-A2125'};
subV = {'sub-V1001' 'sub-V1002' 'sub-V1003' 'sub-V1004' 'sub-V1005' 'sub-V1006' 'sub-V1007' 'sub-V1008' 'sub-V1009' 'sub-V1010' 'sub-V1011' 'sub-V1012' 'sub-V1013' 'sub-V1015' 'sub-V1016' 'sub-V1017' 'sub-V1019' 'sub-V1020' 'sub-V1022' 'sub-V1024' 'sub-V1025' 'sub-V1026' 'sub-V1027' 'sub-V1028' 'sub-V1029' 'sub-V1030' 'sub-V1031' 'sub-V1032' 'sub-V1033' 'sub-V1034' 'sub-V1035' 'sub-V1036' 'sub-V1037' 'sub-V1038' 'sub-V1039' 'sub-V1040' 'sub-V1042' 'sub-V1044' 'sub-V1045' 'sub-V1046' 'sub-V1048' 'sub-V1049' 'sub-V1050' 'sub-V1052' 'sub-V1053' 'sub-V1054' 'sub-V1055' 'sub-V1057' 'sub-V1058' 'sub-V1059' 'sub-V1061' 'sub-V1062' 'sub-V1063' 'sub-V1064' 'sub-V1065' 'sub-V1066' 'sub-V1068' 'sub-V1069' 'sub-V1070' 'sub-V1071' 'sub-V1072' 'sub-V1073' 'sub-V1074' 'sub-V1075' 'sub-V1076' 'sub-V1077' 'sub-V1078' 'sub-V1079' 'sub-V1080' 'sub-V1081' 'sub-V1083' 'sub-V1084' 'sub-V1085' 'sub-V1086' 'sub-V1087' 'sub-V1088' 'sub-V1089' 'sub-V1090' 'sub-V1092' 'sub-V1093' 'sub-V1094' 'sub-V1095' 'sub-V1097' 'sub-V1098' 'sub-V1099' 'sub-V1100' 'sub-V1101' 'sub-V1102' 'sub-V1103' 'sub-V1104' 'sub-V1105' 'sub-V1106' 'sub-V1107' 'sub-V1108' 'sub-V1109' 'sub-V1110' 'sub-V1111' 'sub-V1113' 'sub-V1114' 'sub-V1115' 'sub-V1116' 'sub-V1117'};

numA = length(subA);
numV = length(subV);
num = numA + numV;

id = getenv('PBS_ARRAYID');

if isempty(id)
  % pick a random one between 1 and 204
  id = ceil(rand(1)*num);
else
  id = str2num(id);
end

%%

if id<=numA
  sub = subA{id};
  filename = sprintf('%s_task-auditory_meg.ds', sub);
  dataset = fullfile(bidsroot, sub, 'meg', filename);
  % some recordings are broken up in two runs
  if ~exist(dataset, 'dir')
    filename = sprintf('%s_task-auditory_run-1_meg.ds', sub);
    dataset = fullfile(bidsroot, sub, 'meg', filename);
  end
  if ~exist(dataset, 'dir')
    filename = sprintf('%s_task-auditory_run-2_meg.ds', sub);
    dataset = fullfile(bidsroot, sub, 'meg', filename);
  end
  if ~exist(dataset, 'dir')
    error('cannot identify matching dataset')
  end
else
  sub = subV{id-numA};
  filename = sprintf('%s_task-visual_meg.ds', sub);
  dataset = fullfile(bidsroot, sub, 'meg', filename);
  % some recordings are broken up in two runs
  if ~exist(dataset, 'dir')
    filename = sprintf('%s_task-visual_run-1_meg.ds', sub);
    dataset = fullfile(bidsroot, sub, 'meg', filename);
  end
  if ~exist(dataset, 'dir')
    filename = sprintf('%s_task-visual_run-2_meg.ds', sub);
    dataset = fullfile(bidsroot, sub, 'meg', filename);
  end
  if ~exist(dataset, 'dir')
    error('cannot identify matching dataset')
  end
end

%%

fprintf('RUNNING ON SUBJECT %d:%s\n', id, sub);

%eventsfile = [dataset(1:end-6) 'events.tsv'];

hdr = ft_read_header(dataset);
evt = ft_read_event(dataset);    % from the trigger channe;
%evt = ft_read_event(eventsfile); % from the events.tsv file

%%

% ignore the actual events, just make approximately 200 trials of 1 second that are
% scattered over the whole recording
numsmp = hdr.nSamples*hdr.nTrials;
numtrl = 200;
begsample = sort(round(rand(1,200)*numsmp));
endsample = begsample + hdr.Fs - 1;
offset = zeros(size(begsample)) - round(hdr.Fs/10); % 100 ms prestim

sel = (endsample>numsmp);
begsample(sel) = [];
endsample(sel) = [];
offset(sel) = [];
trl = [begsample(:) endsample(:) offset(:)]; % see FT_DEFINETRIAL


%%
% read the data of the MEG channels and do some minimal preprocessing

numchan = numel(ft_channelselection('MEG', hdr.label));
numsmp = sum(endsample-begsample+1);

fprintf('READING %d CHANNELS\n', numchan);
fprintf('READING %d SAMPLES PER CHANNEL\n', numsmp);
fprintf('READING %d BYTES\n', numchan*numsmp*4);

stopwatch = tic;

cfg = [];
cfg.dataset = dataset;
cfg.trl = trl; % this defines the pieces of data to read
cfg.demean = 'yes';
cfg.baselinewindow = [-inf 0]; % in seconds
cfg.channel = 'MEG';
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

elapsed = toc(stopwatch);

fprintf('READING TOOK %d SECONDS\n', round(elapsed));
fprintf('READING SPEED %.1f MiB/s\n', (numchan*numsmp*4/(elapsed*1024^2)));

