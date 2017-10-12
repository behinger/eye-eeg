function c = parseedf(edffile)

edfdat = edfmex(edffile);

c = struct();
c.comment = {'manual'};
c.colheader =  {'TIME'  'L_GAZE_X'  'L_GAZE_Y'  'L_AREA'  'R_GAZE_X'  'R_GAZE_Y'  'R_AREA'  'INPUT'};
c.data = [edfdat.FSAMPLE.time; edfdat.FSAMPLE.gx;edfdat.FSAMPLE.gy; edfdat.FSAMPLE.pa; edfdat.FSAMPLE.input]';
c.data = permute(c.data,[1 2 4 6 3 5 7 8]);
c.messages = {};


% saccades
sac = struct();
sac.colheader = {'latency'  'endtime'  'duration'  'sac_startpos_x'  'sac_startpos_y'  'sac_endpos_x'  'sac_endpos_y'  'sac_amplitude'  'sac_vmax'};
saccades = strcmp({edfdat.FEVENT.codestring},'ENDSACC');
sacdat = edfdat.FEVENT(saccades);
sac.eye = [sacdat.eye];
tmp = ['L','R'];
sac.eye = tmp(sac.eye+1)';

sac.data = [[sacdat.sttime];
            [sacdat.entime];
            [sacdat.entime]-[sacdat.sttime];
            [sacdat.gstx];
            [sacdat.gsty];
            [sacdat.genx];
            [sacdat.geny];
            sqrt([sacdat.genx].^2 + [sacdat.geny].^2);
            [sacdat.pvel];
            ];
        
sac.data = double(sac.data);
c.eyeevent.saccades = sac;

% fixations
fix = struct();
fix.colheader = {'latency'  'endtime'  'duration'  'fix_avgpos_x'  'fix_avgpos_y'  'fix_avgpupilsize'};
fixations = strcmp({edfdat.FEVENT.codestring},'ENDFIX');
fixdat = edfdat.FEVENT(fixations);
fix.eye = [fixdat.eye];
tmp = ['L','R'];
fix.eye = tmp(fix.eye+1)';

fix.data = [[fixdat.sttime];
            [fixdat.entime];
            [fixdat.entime]-[fixdat.sttime];
            [fixdat.gavx];
            [fixdat.gavy];
            [fixdat.ava];
            ];
fix.data = double(fix.data);
c.eyeevent.fixations = fix;
    

% blinks
blink = struct();
blink.colheader = {'latency'  'endtime'  'duration'};
blinks = strcmp({edfdat.FEVENT.codestring},'ENDBLINK');
blinkdat = edfdat.FEVENT(blinks);
blink.eye = [blinkdat.eye];
tmp = ['L','R'];
blink.eye = tmp(blink.eye+1)';

blink.data = [[blinkdat.sttime];
            [blinkdat.entime];
            [blinkdat.entime]-[blinkdat.sttime];
            ];
blink.data= double(blink.data);
c.eyeevent.blinks = blink;
    




% triggers

msg = find(strcmp({edfdat.FEVENT.codestring},'MESSAGEEVENT'));

trgix = strfind({edfdat.FEVENT(msg).message},'!CMD 0 write_ioport 0x378');
trgix = cellfun(@(x)~isempty(x),trgix);

% adapted from eyeeegtoolbox eyelinkparse
[trgnumber] = regexp({edfdat.FEVENT(msg).message},'!CMD 0 write_ioport 0x378\s?(\d+)','tokens');
% remove all empty hits
trgnumber = [trgnumber{:}];
trgnumber = cellfun(@(x)str2double(x),trgnumber);
trgtime = [edfdat.FEVENT(msg(trgix)).sttime];
c.event = double([trgtime; trgnumber]');
