import { state } from '../shared/state.js';
import { convertFromLanguageNumerals } from '../shared/language.js';

const getCustomVal = (sourceString, index, fallback) => {
	if (!sourceString) return fallback;
	const val = parseFloat(sourceString.split(',')[index]);
	return isNaN(val) ? fallback : val;
};

export const defaultValues = {
	dolbymidvlev: 'OFF',
	dolbymiieq: 'OFF',
	dolbymisurcomp: 'OFF',
	dolbymiadaptvirt: 'OFF',
	dolbymivirtbin: 'OFF',
	dolbymidialenh: 'OFF',
	headphonetuning: 'YES',
	hieq: 'B',
	hieqstr: '6',
	hiet_47: '150',
	hiet_141: '142',
	hiet_234: '188',
	hiet_328: '216',
	hiet_469: '189',
	hiet_656: '195',
	hiet_844: '202',
	hiet_1031: '199',
	hiet_1313: '210',
	hiet_1688: '225',
	hiet_2250: '230',
	hiet_3000: '236',
	hiet_3750: '235',
	hiet_4688: '235',
	hiet_5813: '214',
	hiet_7125: '165',
	hiet_9000: '112',
	hiet_11250: '49',
	hiet_13875: '-24',
	hiet_19688: '-217',
	hieqstr: '6',
	heq_47: '0',
	heq_141: '0',
	heq_234: '0',
	heq_328: '0',
	heq_469: '0',
	heq_656: '0',
	heq_844: '0',
	heq_1031: '0',
	heq_1313: '0',
	heq_1688: '0',
	heq_2250: '0',
	heq_3000: '0',
	heq_3750: '0',
	heq_4688: '0',
	heq_5813: '0',
	heq_7125: '0',
	heq_9000: '0',
	heq_11250: '0',
	heq_13875: '0',
	heq_19688: '0',
	heqpreset: 'flat',
	hrenderbass: 'VB',
	hbassboost: '6',
	hbasscutoff: '90',
	hbasswidth: '16',
	hbassharmtype: '3',
	hbassharmsrcfreqmin: '10',
	hbassharmsrcfreqmax: '90',
	hbassharmmixfreqmin: '10',
	hbassharmmixfreqmax: '90',
	hbassharmgenfreqmax: '240',
	hbassharmboost: '6',
	hbasslingain: '7',
	hbasscompstrength: '0',
	hvolboost: '0',
	hde: '0',
	hdea: '6',
	hded: '0',
	hvirtdist: '40',
	hsurboost: '3',
	hvirtualizer: '1',
	hadvirtangle: '90',
	hvirtmod: '2',
	hadvirtrend: '103,32568,11164,5090,0,3,3,3',
	hheightfilter: '1',
	hleveler: 'OFF',
	hlevstr: '3',
	hlevamount: '0',
	hlevtargetin: '6',
	hlevtargetout: '6',
	hregulator: 'ON',
	hregoverdrive: '0',
	htimbre: '3',
	htunedrate: '48000',
	h_output_channels: '2',
	speakertuning: 'YES',
	sieq: 'B',
	siet_47: '150',
	siet_141: '142',
	siet_234: '188',
	siet_328: '216',
	siet_469: '189',
	siet_656: '195',
	siet_844: '202',
	siet_1031: '199',
	siet_1313: '210',
	siet_1688: '225',
	siet_2250: '230',
	siet_3000: '236',
	siet_3750: '235',
	siet_4688: '235',
	siet_5813: '214',
	siet_7125: '165',
	siet_9000: '112',
	siet_11250: '49',
	siet_13875: '-24',
	siet_19688: '-217',
	sieqstr: '6',
	seq_47: '0',
	seq_141: '0',
	seq_234: '0',
	seq_328: '0',
	seq_469: '0',
	seq_656: '0',
	seq_844: '0',
	seq_1031: '0',
	seq_1313: '0',
	seq_1688: '0',
	seq_2250: '0',
	seq_3000: '0',
	seq_3750: '0',
	seq_4688: '0',
	seq_5813: '0',
	seq_7125: '0',
	seq_9000: '0',
	seq_11250: '0',
	seq_13875: '0',
	seq_19688: '0',
	seqpreset: 'flat',
	srenderbass: 'VB',
	sbassboost: '6',
	sbassharmtype: '3',
	sbassharmboost: '5',
	sbasslingain: '5',
	sbasscompstrength: '0',
	svolboost: '0',
	sde: '0',
	sdea: '6',
	sded: '0',
	ssurboost: '3',
	svirtualizer: '1',
	svirtmod: '2',
	sadvirtrend: '103,32568,11164,5090,0,3,3,3',
	sleveler: 'OFF',
	slevstr: '3',
	slevamount: '0',
	slevtargetin: '6',
	slevtargetout: '6',
	stimbre: '3',
	stunedrate: '48000',
	s_output_channels: '2'
};

export const equalizerPresets = {
	flat: '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0',
	bass_emphasis: '6,4,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0',
	treble_emphasis: '0,0,0,0,0,0,0,0,0,0,0,0,0,2,4,6,6,4,3,2',
	vocal_clarity: '0,0,0,1,2,3,4,5,6,6,5,4,3,2,1,0,0,0,0,0',
	pop_rock: '6,4,2,0,0,0,1,2,3,3,2,1,0,0,2,3,4,3,2,1',
	electro_dance: '8,6,4,2,0,0,0,0,0,0,0,0,0,1,3,5,6,5,3,2',
	edm: '8,7,5,3,1,0,0,0,0,1,2,2,1,0,2,4,6,5,4,2',
	drum_bass: '7,6,4,2,0,0,1,2,2,1,0,0,1,2,3,4,5,4,3,1',
	classical_acoustic: '2,1,0,0,1,2,3,3,2,1,0,0,1,2,3,2,1,1,0,0',
	metal: '6,5,3,2,1,0,1,2,3,4,4,3,2,1,2,3,4,3,2,1',
	reggae: '7,6,4,2,1,0,0,1,2,3,3,2,1,0,0,1,2,2,1,0',
	loudness: '4,3,2,1,0,0,1,2,3,4,4,3,2,2,3,4,5,4,3,2',
	custom: '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'
};

export const configMap = {
	
	DOLBYMIDVLEV: { id: 'dolbymidvlev', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	DOLBYMIIEQ: { id: 'dolbymiieq', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	DOLBYMISURCOMP: { id: 'dolbymisurcomp', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	DOLBYMIADAPTVIRT: { id: 'dolbymiadaptvirt', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	DOLBYMIVIRTBIN: { id: 'dolbymivirtbin', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	DOLBYMIDIALENH: { id: 'dolbymidialenh', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	HEADPHONETUNING: { id: 'headphonetuning', type: 'toggle', default: 'YES', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'YES' : 'NO' },
	HIEQ: { id: 'hieq', type: 'select', default: 'B', transform: (el) => el ? el.value : 'B' },
	HIEQSTR: { id: 'hieqstr', type: 'range', default: '6' },
	HEQPRESET: { id: 'heqpreset', type: 'select', default: 'flat', transform: (el) => el ? el.value : 'flat' },
	HIET_1: { id: 'hiet47', type: 'range', default: '150', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_47'] : getCustomVal(state.hieqCustomValues, 0, 150) },
	HIET_2: { id: 'hiet141', type: 'range', default: '142', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_141'] : getCustomVal(state.hieqCustomValues, 1, 142) },
	HIET_3: { id: 'hiet234', type: 'range', default: '188', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_234'] : getCustomVal(state.hieqCustomValues, 2, 188) },
	HIET_4: { id: 'hiet328', type: 'range', default: '216', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_328'] : getCustomVal(state.hieqCustomValues, 3, 216) },
	HIET_5: { id: 'hiet469', type: 'range', default: '189', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_469'] : getCustomVal(state.hieqCustomValues, 4, 189) },
	HIET_6: { id: 'hiet656', type: 'range', default: '195', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_656'] : getCustomVal(state.hieqCustomValues, 5, 195) },
	HIET_7: { id: 'hiet844', type: 'range', default: '202', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_844'] : getCustomVal(state.hieqCustomValues, 6, 202) },
	HIET_8: { id: 'hiet1031', type: 'range', default: '199', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_1031'] : getCustomVal(state.hieqCustomValues, 7, 199) },
	HIET_9: { id: 'hiet1313', type: 'range', default: '210', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_1313'] : getCustomVal(state.hieqCustomValues, 8, 210) },
	HIET_10: { id: 'hiet1688', type: 'range', default: '225', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_1688'] : getCustomVal(state.hieqCustomValues, 9, 225) },
	HIET_11: { id: 'hiet2250', type: 'range', default: '230', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_2250'] : getCustomVal(state.hieqCustomValues, 10, 230) },
	HIET_12: { id: 'hiet3000', type: 'range', default: '236', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_3000'] : getCustomVal(state.hieqCustomValues, 11, 236) },
	HIET_13: { id: 'hiet3750', type: 'range', default: '235', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_3750'] : getCustomVal(state.hieqCustomValues, 12, 235) },
	HIET_14: { id: 'hiet4688', type: 'range', default: '235', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_4688'] : getCustomVal(state.hieqCustomValues, 13, 235) },
	HIET_15: { id: 'hiet5813', type: 'range', default: '214', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_5813'] : getCustomVal(state.hieqCustomValues, 14, 214) },
	HIET_16: { id: 'hiet7125', type: 'range', default: '165', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_7125'] : getCustomVal(state.hieqCustomValues, 15, 165) },
	HIET_17: { id: 'hiet9000', type: 'range', default: '112', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_9000'] : getCustomVal(state.hieqCustomValues, 16, 112) },
	HIET_18: { id: 'hiet11250', type: 'range', default: '49', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_11250'] : getCustomVal(state.hieqCustomValues, 17, 49) },
	HIET_19: { id: 'hiet13875', type: 'range', default: '-24', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_13875'] : getCustomVal(state.hieqCustomValues, 18, -24) },
	HIET_20: { id: 'hiet19688', type: 'range', default: '-217', transform: (el) => (state.domCache.hieq?.value !== 'C' && state.domCache.hieq?.value !== 'CB') ? defaultValues['hiet_19688'] : getCustomVal(state.hieqCustomValues, 19, -217) },
	HEQ_1: { id: 'heq47', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[0] : (parseFloat(state.heqCustomValues.split(',')[0] || '0')) },
	HEQ_2: { id: 'heq141', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[1] : (parseFloat(state.heqCustomValues.split(',')[1] || '0')) },
	HEQ_3: { id: 'heq234', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[2] : (parseFloat(state.heqCustomValues.split(',')[2] || '0')) },
	HEQ_4: { id: 'heq328', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[3] : (parseFloat(state.heqCustomValues.split(',')[3] || '0')) },
	HEQ_5: { id: 'heq469', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[4] : (parseFloat(state.heqCustomValues.split(',')[4] || '0')) },
	HEQ_6: { id: 'heq656', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[5] : (parseFloat(state.heqCustomValues.split(',')[5] || '0')) },
	HEQ_7: { id: 'heq844', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[6] : (parseFloat(state.heqCustomValues.split(',')[6] || '0')) },
	HEQ_8: { id: 'heq1031', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[7] : (parseFloat(state.heqCustomValues.split(',')[7] || '0')) },
	HEQ_9: { id: 'heq1313', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[8] : (parseFloat(state.heqCustomValues.split(',')[8] || '0')) },
	HEQ_10: { id: 'heq1688', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[9] : (parseFloat(state.heqCustomValues.split(',')[9] || '0')) },
	HEQ_11: { id: 'heq2250', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[10] : (parseFloat(state.heqCustomValues.split(',')[10] || '0')) },
	HEQ_12: { id: 'heq3000', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[11] : (parseFloat(state.heqCustomValues.split(',')[11] || '0')) },
	HEQ_13: { id: 'heq3750', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[12] : (parseFloat(state.heqCustomValues.split(',')[12] || '0')) },
	HEQ_14: { id: 'heq4688', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[13] : (parseFloat(state.heqCustomValues.split(',')[13] || '0')) },
	HEQ_15: { id: 'heq5813', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[14] : (parseFloat(state.heqCustomValues.split(',')[14] || '0')) },
	HEQ_16: { id: 'heq7125', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[15] : (parseFloat(state.heqCustomValues.split(',')[15] || '0')) },
	HEQ_17: { id: 'heq9000', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[16] : (parseFloat(state.heqCustomValues.split(',')[16] || '0')) },
	HEQ_18: { id: 'heq11250', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[17] : (parseFloat(state.heqCustomValues.split(',')[17] || '0')) },
	HEQ_19: { id: 'heq13875', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[18] : (parseFloat(state.heqCustomValues.split(',')[18] || '0')) },
	HEQ_20: { id: 'heq19688', type: 'range', default: '0', transform: (el) => state.domCache.heqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.heqpreset?.value || 'flat'].split(',')[19] : (parseFloat(state.heqCustomValues.split(',')[19] || '0')) },
	HRENDERBASS: { id: 'hrenderbass', type: 'toggle', default: 'VB', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'BE' : 'VB' },
	HBASSBOOST: { id: 'hbassboost', type: 'range', default: '6' },
	HBASSCUTOFF: { id: 'hbasscutoff', type: 'range', default: '90' },
	HBASSWIDTH: { id: 'hbasswidth', type: 'range', default: '16' },
	HBASSHARMTYPE: { id: 'hbassharmtype', type: 'range', default: '3' },
	HBASSHARMSRCFREQMIN: { id: 'hbassharmsrcfreqmin', type: 'range', default: '10' },
	HBASSHARMSRCFREQMAX: { id: 'hbassharmsrcfreqmax', type: 'range', default: '90' },
	HBASSHARMMIXFREQMIN: { id: 'hbassharmmixfreqmin', type: 'range', default: '10' },
	HBASSHARMMIXFREQMAX: { id: 'hbassharmmixfreqmax', type: 'range', default: '90' },
	HBASSHARMGENFREQMAX: { id: 'hbassharmgenfreqmax', type: 'range', default: '240' },
	HBASSHARMBOOST: { id: 'hbassharmboost', type: 'range', default: '6' },
	HBASSLINGAIN: { id: 'hbasslingain', type: 'range', default: '7' },
	HBASSCOMPSTRENGTH: { id: 'hbasscompstrength', type: 'range', default: '0' },
	HVOLBOOST: { id: 'hvolboost', type: 'range', default: '0' },
	HVOLBALANCE: { id: 'hvolbalance', type: 'range', default: '0' },
	HDE: { id: 'hde', type: 'select', default: '0' },
	HDEA: { id: 'hdea', type: 'range', default: '6' },
	HDED: { id: 'hded', type: 'range', default: '0' },
	HVIRTDIST: { id: 'hvirtdist', type: 'range', default: '40' },
	HSURBOOST: { id: 'hsurboost', type: 'range', default: '3' },
	HVIRTUALIZER: { id: 'hvirtualizer', type: 'select', default: '1' },
	HADVIRTANGLE: { id: 'hadvirtangle', type: 'range', default: '90' },
	HVIRTMOD: { id: 'hvirtmod', type: 'select', default: '2' },
	HADVIRTREND: { id: 'hadvirtrend', type: 'select', default: '103,32568,11164,5090,0,3,3,3', transform: (el) => { if (el && el.value && el.value !== 'custom') { return el.value; } return state.hadvirtrend; } },
	HHEIGHTFILTER: { id: 'hheightfilter', type: 'select', default: '1' },
	HLEVELER: { id: 'hleveler', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	HLEVSTR: { id: 'hlevstr', type: 'range', default: '3' },
	HLEVAMOUNT: { id: 'hlevamount', type: 'range', default: '0' },
	HLEVTARGETIN: { id: 'hlevtargetin', type: 'range', default: '6' },
	HLEVTARGETOUT: { id: 'hlevtargetout', type: 'range', default: '6' },
	HREGULATOR: { id: 'hregulator', type: 'toggle', default: 'ON', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	HREGOVERDRIVE: { id: 'hregoverdrive', type: 'range', default: '0' },
	HTIMBRE: { id: 'htimbre', type: 'range', default: '3' },
	HTUNEDRATE: { id: 'htunedrate', type: 'select', default: '48000' },
	H_OUTPUT_CHANNELS: { id: 'h_output_channels', type: 'select', default: '2' },
	SPEAKERTUNING: { id: 'speakertuning', type: 'toggle', default: 'YES', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'YES' : 'NO' },
	SIEQ: { id: 'sieq', type: 'select', default: 'B' },
	SIET_1: { id: 'siet47', type: 'range', default: '150', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_47'] : getCustomVal(state.sieqCustomValues, 0, 150) },
	SIET_2: { id: 'siet141', type: 'range', default: '142', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_141'] : getCustomVal(state.sieqCustomValues, 1, 142) },
	SIET_3: { id: 'siet234', type: 'range', default: '188', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_234'] : getCustomVal(state.sieqCustomValues, 2, 188) },
	SIET_4: { id: 'siet328', type: 'range', default: '216', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_328'] : getCustomVal(state.sieqCustomValues, 3, 216) },
	SIET_5: { id: 'siet469', type: 'range', default: '189', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_469'] : getCustomVal(state.sieqCustomValues, 4, 189) },
	SIET_6: { id: 'siet656', type: 'range', default: '195', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_656'] : getCustomVal(state.sieqCustomValues, 5, 195) },
	SIET_7: { id: 'siet844', type: 'range', default: '202', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_844'] : getCustomVal(state.sieqCustomValues, 6, 202) },
	SIET_8: { id: 'siet1031', type: 'range', default: '199', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_1031'] : getCustomVal(state.sieqCustomValues, 7, 199) },
	SIET_9: { id: 'siet1313', type: 'range', default: '210', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_1313'] : getCustomVal(state.sieqCustomValues, 8, 210) },
	SIET_10: { id: 'siet1688', type: 'range', default: '225', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_1688'] : getCustomVal(state.sieqCustomValues, 9, 225) },
	SIET_11: { id: 'siet2250', type: 'range', default: '230', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_2250'] : getCustomVal(state.sieqCustomValues, 10, 230) },
	SIET_12: { id: 'siet3000', type: 'range', default: '236', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_3000'] : getCustomVal(state.sieqCustomValues, 11, 236) },
	SIET_13: { id: 'siet3750', type: 'range', default: '235', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_3750'] : getCustomVal(state.sieqCustomValues, 12, 235) },
	SIET_14: { id: 'siet4688', type: 'range', default: '235', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_4688'] : getCustomVal(state.sieqCustomValues, 13, 235) },
	SIET_15: { id: 'siet5813', type: 'range', default: '214', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_5813'] : getCustomVal(state.sieqCustomValues, 14, 214) },
	SIET_16: { id: 'siet7125', type: 'range', default: '165', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_7125'] : getCustomVal(state.sieqCustomValues, 15, 165) },
	SIET_17: { id: 'siet9000', type: 'range', default: '112', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_9000'] : getCustomVal(state.sieqCustomValues, 16, 112) },
	SIET_18: { id: 'siet11250', type: 'range', default: '49', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_11250'] : getCustomVal(state.sieqCustomValues, 17, 49) },
	SIET_19: { id: 'siet13875', type: 'range', default: '-24', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_13875'] : getCustomVal(state.sieqCustomValues, 18, -24) },
	SIET_20: { id: 'siet19688', type: 'range', default: '-217', transform: (el) => (state.domCache.sieq?.value !== 'C' && state.domCache.sieq?.value !== 'CD') ? defaultValues['siet_19688'] : getCustomVal(state.sieqCustomValues, 19, -217) },
	SIEQSTR: { id: 'sieqstr', type: 'range', default: '6' },
	SEQPRESET: { id: 'seqpreset', type: 'select', default: 'flat', transform: (el) => el ? el.value : 'flat' },
	SEQ_1: { id: 'seq47', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[0] : (parseFloat(state.seqCustomValues.split(',')[0] || '0')) },
	SEQ_2: { id: 'seq141', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[1] : (parseFloat(state.seqCustomValues.split(',')[1] || '0')) },
	SEQ_3: { id: 'seq234', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[2] : (parseFloat(state.seqCustomValues.split(',')[2] || '0')) },
	SEQ_4: { id: 'seq328', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[3] : (parseFloat(state.seqCustomValues.split(',')[3] || '0')) },
	SEQ_5: { id: 'seq469', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[4] : (parseFloat(state.seqCustomValues.split(',')[4] || '0')) },
	SEQ_6: { id: 'seq656', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[5] : (parseFloat(state.seqCustomValues.split(',')[5] || '0')) },
	SEQ_7: { id: 'seq844', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[6] : (parseFloat(state.seqCustomValues.split(',')[6] || '0')) },
	SEQ_8: { id: 'seq1031', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[7] : (parseFloat(state.seqCustomValues.split(',')[7] || '0')) },
	SEQ_9: { id: 'seq1313', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[8] : (parseFloat(state.seqCustomValues.split(',')[8] || '0')) },
	SEQ_10: { id: 'seq1688', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[9] : (parseFloat(state.seqCustomValues.split(',')[9] || '0')) },
	SEQ_11: { id: 'seq2250', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[10] : (parseFloat(state.seqCustomValues.split(',')[10] || '0')) },
	SEQ_12: { id: 'seq3000', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[11] : (parseFloat(state.seqCustomValues.split(',')[11] || '0')) },
	SEQ_13: { id: 'seq3750', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[12] : (parseFloat(state.seqCustomValues.split(',')[12] || '0')) },
	SEQ_14: { id: 'seq4688', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[13] : (parseFloat(state.seqCustomValues.split(',')[13] || '0')) },
	SEQ_15: { id: 'seq5813', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[14] : (parseFloat(state.seqCustomValues.split(',')[14] || '0')) },
	SEQ_16: { id: 'seq7125', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[15] : (parseFloat(state.seqCustomValues.split(',')[15] || '0')) },
	SEQ_17: { id: 'seq9000', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[16] : (parseFloat(state.seqCustomValues.split(',')[16] || '0')) },
	SEQ_18: { id: 'seq11250', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[17] : (parseFloat(state.seqCustomValues.split(',')[17] || '0')) },
	SEQ_19: { id: 'seq13875', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[18] : (parseFloat(state.seqCustomValues.split(',')[18] || '0')) },
	SEQ_20: { id: 'seq19688', type: 'range', default: '0', transform: (el) => state.domCache.seqpreset?.value !== 'custom' ? equalizerPresets[state.domCache.seqpreset?.value || 'flat'].split(',')[19] : (parseFloat(state.seqCustomValues.split(',')[19] || '0')) },
	SRENDERBASS: { id: 'srenderbass', type: 'toggle', default: 'VB', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'BE' : 'VB' },
	SBASSBOOST: { id: 'sbassboost', type: 'range', default: '6' },
	SBASSHARMTYPE: { id: 'sbassharmtype', type: 'range', default: '3' },
	SBASSHARMBOOST: { id: 'sbassharmboost', type: 'range', default: '5' },
	SBASSLINGAIN: { id: 'sbasslingain', type: 'range', default: '5' },
	SBASSCOMPSTRENGTH: { id: 'sbasscompstrength', type: 'range', default: '0' },
	SVOLBOOST: { id: 'svolboost', type: 'range', default: '0' },
	SDE: { id: 'sde', type: 'select', default: '0' },
	SDEA: { id: 'sdea', type: 'range', default: '6' },
	SDED: { id: 'sded', type: 'range', default: '0' },
	SSURBOOST: { id: 'ssurboost', type: 'range', default: '3' },
	SVIRTUALIZER: { id: 'svirtualizer', type: 'select', default: '1' },
	SVIRTMOD: { id: 'svirtmod', type: 'select', default: '2' },
	SADVIRTREND: { id: 'sadvirtrend', type: 'select', default: '103,32568,11164,5090,0,3,3,3', transform: (el) => { if (el && el.value && el.value !== 'custom') { return el.value; } return state.sadvirtrend; } },
	SLEVELER: { id: 'sleveler', type: 'toggle', default: 'OFF', transform: (el) => el && el.getAttribute('data-state') === 'true' ? 'ON' : 'OFF' },
	SLEVSTR: { id: 'slevstr', type: 'range', default: '3' },
	SLEVAMOUNT: { id: 'slevamount', type: 'range', default: '0' },
	SLEVTARGETIN: { id: 'slevtargetin', type: 'range', default: '6' },
	SLEVTARGETOUT: { id: 'slevtargetout', type: 'range', default: '6' },
	STIMBRE: { id: 'stimbre', type: 'range', default: '3' },
	STUNEDRATE: { id: 'stunedrate', type: 'select', default: '48000' },
	S_OUTPUT_CHANNELS: { id: 's_output_channels', type: 'select', default: '2' }
};

export const visibilityMap = {
	headphone: {
		ieqCustomInput: { id: 'hieqCustomInput', showWhen: () => state.domCache.hieq?.value === 'C' || state.domCache.hieq?.value === 'CB'},
		bassboostContainer: { id: 'hbassboostContainer', showWhen: (_, isVB) => !isVB },
		basscutoffContainer: { id: 'hbasscutoffContainer', showWhen: (_, isVB) => !isVB },
		basswidthContainer: { id: 'hbasswidthContainer', showWhen: (_, isVB) => !isVB },
		bassharmtextContainer: { id: 'hbassharmtextContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmtypeContainer: { id: 'hbassharmtypeContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmsrcfreqminContainer: { id: 'hbassharmsrcfreqminContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmsrcfreqmaxContainer: { id: 'hbassharmsrcfreqmaxContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmmixfreqminContainer: { id: 'hbassharmmixfreqminContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmmixfreqmaxContainer: { id: 'hbassharmmixfreqmaxContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmgenfreqmaxContainer: { id: 'hbassharmgenfreqmaxContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmboostContainer: { id: 'hbassharmboostContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		basslingainContainer: { id: 'hbasslingainContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		basscompstrengthContainer: { id: 'hbasscompstrengthContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		advirtangleContainer: { id: 'hadvirtangleContainer', showWhen: (isSimpleMode) => !isSimpleMode && state.supportedFeatures.angle },
		advirtdistContainer: { id: 'hvirtdistContainer', showWhen: (isSimpleMode) => !isSimpleMode && state.supportedFeatures.distance },
		advirtrendContainer: { id: 'hadvirtrendContainer', showWhen: (isSimpleMode) => !isSimpleMode && state.supportedFeatures.hadvancedvirt },
		virtmodContainer: { id: 'hvirtmodContainer', showWhen: (isSimpleMode) => !isSimpleMode && state.supportedFeatures.hvirtmode },
		ieqstrContainer: { id: 'hieqstrContainer', showWhen: () => true },
		eqPreset: { id: 'heqpreset', showWhen: () => true },
		deContainer: { id: 'hdeContainer', showWhen: () => true },
		deaContainer: { id: 'hdeaContainer', showWhen: () => true },
		dedContainer: { id: 'hdedContainer', showWhen: () => true },
		virtualizerContainer: { id: 'hvirtualizerContainer', showWhen: () => true },
		surboostContainer: { id: 'hsurboostContainer', showWhen: () => true  },
		heightfilterContainer: { id: 'hheightfilterContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		levstrContainer: { id: 'hlevstrContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		levamountContainer: { id: 'hlevamountContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		levtargetinContainer: { id: 'hlevtargetinContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		levtargetoutContainer: { id: 'hlevtargetoutContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		regulatorContainer: { id: 'hregulatorContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		regoverdriveContainer: { id: 'hregoverdriveContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		timbreContainer: { id: 'htimbreContainer', showWhen: () => true },
		tunedrateContainer: { id: 'htunedrateContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		output_channelsContainer: { id: 'h_output_channelsContainer', showWhen: (isSimpleMode) => !isSimpleMode }
	},
	speaker: {
		ieqCustomInput: { id: 'sieqCustomInput', showWhen: () => state.domCache.sieq?.value === 'C' || state.domCache.sieq?.value === 'CD'},
		bassboostContainer: { id: 'sbassboostContainer', showWhen: (_, isVB) => !isVB },
		basscutoffContainer: { id: 'sbasscutoffContainer', showWhen: (_, isVB) => !isVB },
		basswidthContainer: { id: 'sbasswidthContainer', showWhen: (_, isVB) => !isVB },
		bassharmtextContainer: { id: 'sbassharmtextContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmtypeContainer: { id: 'sbassharmtypeContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		bassharmboostContainer: { id: 'sbassharmboostContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		basslingainContainer: { id: 'sbasslingainContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		basscompstrengthContainer: { id: 'sbasscompstrengthContainer', showWhen: (_, isVB, features) => isVB && features.harm },
		advirtrendContainer: { id: 'sadvirtrendContainer', showWhen: (isSimpleMode) => !isSimpleMode && state.supportedFeatures.sadvancedvirt },
		virtmodContainer: { id: 'svirtmodContainer', showWhen: (isSimpleMode) => !isSimpleMode && state.supportedFeatures.svirtmode },
		ieqstrContainer: { id: 'sieqstrContainer', showWhen: () => true },
		deContainer: { id: 'sdeContainer', showWhen: () => true },
		deaContainer: { id: 'sdeaContainer', showWhen: () => true },
		dedContainer: { id: 'sdedContainer', showWhen: () => true },
		virtualizerContainer: { id: 'svirtualizerContainer', showWhen: () => true },
		surboostContainer: { id: 'ssurboostContainer', showWhen: () => true },
		levstrContainer: { id: 'slevstrContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		levamountContainer: { id: 'slevamountContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		levtargetinContainer: { id: 'slevtargetinContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		levtargetoutContainer: { id: 'slevtargetoutContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		timbreContainer: { id: 'stimbreContainer', showWhen: () => true },
		tunedrateContainer: { id: 'stunedrateContainer', showWhen: (isSimpleMode) => !isSimpleMode },
		output_channelsContainer: { id: 's_output_channelsContainer', showWhen: (isSimpleMode) => !isSimpleMode }
	}
};

export const translationMaps = {
	virtMod: { '1': 'center_oriented', '2': 'expanded' },
	dialogEnhancer: { '0': 'off', '1': 'movie_profile_only', '2': 'all_profiles' },
	ieq: { 'B': 'balanced', 'D': 'detailed', 'W': 'warm', 'C': 'custom', 'N': 'no_ieq' },
	heightFilter: { '0': 'off', '1': 'slightly_elevated', '2': 'more_elevated' },
	advVirtRend: {
		'103,32568,11164,5090,0,3,3,3': 'stock',
		'160,32767,14379,7090,2,2,3,1': 'option_1',
		'200,32767,16379,7090,3,3,3,1': 'option_2',
		'160,32767,16379,2065,0,3,3,0': 'motorola_spatializer',
		'103,32568,11164,5090,0,1,2,2': 'xiaomi_15_spatializer',
		'200,32568,15164,8090,1,2,2,1': 'ShadoV_favorite_1',
		'200,32568,15164,8090,1,2,3,1': 'ShadoV_favorite_2',
		'360,65535,8192,4096,0,3,2,2': 'ShadoV_favorite_3'
	},
	timbre: { '1': 'level_1', '2': 'level_2', '3': 'level_3', '4': 'level_4' }
};

const heqDefaultKeys = [
	'heq_47', 'heq_141', 'heq_234', 'heq_328', 'heq_469', 'heq_656', 'heq_844', 
	'heq_1031', 'heq_1313', 'heq_1688', 'heq_2250', 'heq_3000', 'heq_3750', 
	'heq_4688', 'heq_5813', 'heq_7125', 'heq_9000', 'heq_11250', 'heq_13875', 'heq_19688'
];

const hietDefaultKeys = [
	'hiet_47', 'hiet_141', 'hiet_234', 'hiet_328', 'hiet_469', 'hiet_656', 
	'hiet_844', 'hiet_1031', 'hiet_1313', 'hiet_1688', 'hiet_2250', 'hiet_3000', 
	'hiet_3750', 'hiet_4688', 'hiet_5813', 'hiet_7125', 'hiet_9000', 'hiet_11250', 
	'hiet_13875', 'hiet_19688'
];

const sietDefaultKeys = [
	'siet_47', 'siet_141', 'siet_234', 'siet_328', 'siet_469', 'siet_656', 
	'siet_844', 'siet_1031', 'siet_1313', 'siet_1688', 'siet_2250', 'siet_3000', 
	'siet_3750', 'siet_4688', 'siet_5813', 'siet_7125', 'siet_9000', 'siet_11250', 
	'siet_13875', 'siet_19688'
];
4
defaultValues.heqCustomValues = heqDefaultKeys
	.map(key => defaultValues[key])
	.join(',');

defaultValues.hieqCustomValues = hietDefaultKeys
	.map(key => defaultValues[key])
	.join(',');

defaultValues.sieqCustomValues = sietDefaultKeys
	.map(key => defaultValues[key])
	.join(',');

export const generateConfigString = () => {
	const config = {};
	const lang = state.domCache.languageSelect?.value || 'en';
	for (const [key, configEntry] of Object.entries(configMap)) {
	const el = state.domCache[configEntry.id];
	let value;

	if (!el) {
		console.warn(`generateConfigString: Element not found for key=${key}, id=${configEntry.id}, using default.`);
		value = configEntry.default;
	} else if (configEntry.transform) {
		value = configEntry.transform(el);
	} else {
		value = configEntry.type === 'toggle' ? el.getAttribute('data-state') : el.value;
	}

	if (value === null || value === undefined || value === '') {
		console.warn(`generateConfigString: Value for key=${key} was invalid, empty, or null. Falling back to default: ${configEntry.default}`);
		value = configEntry.default;
	}

	if (configEntry.type === 'range') {
		const converted = convertFromLanguageNumerals(value.toString(), lang);
		const parsed = parseFloat(converted);
		if (isNaN(parsed)) {
			console.warn(`generateConfigString: NaN detected for key=${key}, rawValue=${value}, converted=${converted}, using default=${configEntry.default}`);
			value = parseFloat(configEntry.default);
		} else {
			value = parsed;
		}
	}
	config[key.toLowerCase()] = value.toString();
	}
	return `
V=60
### Dolby tuning DIY
#Blank or wrong filled variable will cause setting default value

-----------------------------------
#########################
### HEADPHONE SECTION ###
#########################
-----------------------------------

# Dolby Media Intelligence 
# (Dolby choose values and parameters itself)
# should it be turned ON or OFF globally?
# Values [ON or OFF] (default OFF)

DOLBYMIDVLEV=${config.dolbymidvlev}
DOLBYMIIEQ=${config.dolbymiieq}
DOLBYMISURCOMP=${config.dolbymisurcomp}
DOLBYMIADAPTVIRT=${config.dolbymiadaptvirt}
DOLBYMIVIRTBIN=${config.dolbymivirtbin}
DOLBYMIDIALENH=${config.dolbymidialenh}

-----------------------------------

# Do you want to modify your headphones experience?
# Values [YES or NO] (default YES)

HEADPHONETUNING=${config.headphonetuning}

-----------------------------------

# Which Intelligent EQ preset you want? 
# (values B - Balanced, D - Detailed, W - Warm, N - Disabled IEQ)
# You can also create your own profile with targets specified below
# (C - Custom new ieq profile, CB - Custom new ieq profile (Override Balanced))
# (default and stock: B)

HIEQ=${config.hieq}

#INTELLIGENT EQUALIZER
# Values [-500 to 500]
# HIEQ must be set to "C" or "CB" to freely change values

HIET_1=${parseFloat(config.hiet_1)}
HIET_2=${parseFloat(config.hiet_2)}
HIET_3=${parseFloat(config.hiet_3)}
HIET_4=${parseFloat(config.hiet_4)}
HIET_5=${parseFloat(config.hiet_5)}
HIET_6=${parseFloat(config.hiet_6)}
HIET_7=${parseFloat(config.hiet_7)}
HIET_8=${parseFloat(config.hiet_8)}
HIET_9=${parseFloat(config.hiet_9)}
HIET_10=${parseFloat(config.hiet_10)}
HIET_11=${parseFloat(config.hiet_11)}
HIET_12=${parseFloat(config.hiet_12)}
HIET_13=${parseFloat(config.hiet_13)}
HIET_14=${parseFloat(config.hiet_14)}
HIET_15=${parseFloat(config.hiet_15)}
HIET_16=${parseFloat(config.hiet_16)}
HIET_17=${parseFloat(config.hiet_17)}
HIET_18=${parseFloat(config.hiet_18)}
HIET_19=${parseFloat(config.hiet_19)}
HIET_20=${parseFloat(config.hiet_20)}

-----------------------------------

# How strong Intelligent EQ should be? 
# Generally values: 1-3 is weak, 4-6 is medium, 7-10 is strong, 10-15 is very strong, 16-20 is extreme
# ** stock values differ, mostly 3-8 **
# values [1-20] (default: 6)

HIEQSTR=${config.hieqstr}

-----------------------------------

# Headphone Equalizer Preset
# Values [flat, bass_emphasis, treble_emphasis, vocal_clarity, custom] (default: flat)

HEQPRESET=${config.heqpreset}

-----------------------------------

#EQUALIZER
# Values [-12 to 12] (default: 0 for all frequencies)
# HEQPRESET must be set to custom to freely change values

HEQ_1=${parseFloat(config.heq_1)}
HEQ_2=${parseFloat(config.heq_2)}
HEQ_3=${parseFloat(config.heq_3)}
HEQ_4=${parseFloat(config.heq_4)}
HEQ_5=${parseFloat(config.heq_5)}
HEQ_6=${parseFloat(config.heq_6)}
HEQ_7=${parseFloat(config.heq_7)}
HEQ_8=${parseFloat(config.heq_8)}
HEQ_9=${parseFloat(config.heq_9)}
HEQ_10=${parseFloat(config.heq_10)}
HEQ_11=${parseFloat(config.heq_11)}
HEQ_12=${parseFloat(config.heq_12)}
HEQ_13=${parseFloat(config.heq_13)}
HEQ_14=${parseFloat(config.heq_14)}
HEQ_15=${parseFloat(config.heq_15)}
HEQ_16=${parseFloat(config.heq_16)}
HEQ_17=${parseFloat(config.heq_17)}
HEQ_18=${parseFloat(config.heq_18)}
HEQ_19=${parseFloat(config.heq_19)}
HEQ_20=${parseFloat(config.heq_20)}

-----------------------------------

# Bass enhancer (BE) or Virtual Bass (VB)?
# values [BE or VB] (default: Virtual Bass)

HRENDERBASS=${config.hrenderbass}

-----------------------------------

# This parameter work ONLY with Bass Enhancer
# How strong Bass Enhancer boost you want?
# ** stock settings uses wide range, from 2 to 6 **
# values [0-30] (default: 6)

HBASSBOOST=${config.hbassboost}

-----------------------------------

# This parameter work ONLY with Bass Enhancer
# Where bass enhancer should cut its boost?
# ** stock settings uses wide range **
# values [10-200] (default: 90)

HBASSCUTOFF=${config.hbasscutoff}

-----------------------------------

# This parameter work ONLY with Bass Enhancer
# How broad Bass Enhancer boost you want around cutoff?
# ** stock settings mostly use ranges from 16 to 32 **
# values [1-128] (default: 16)

HBASSWIDTH=${config.hbasswidth}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Each value will result with different virtual bass sound (proportions: second/third/fourth harmonic)
# Value of 1 have higher values for second harmonic than third and fourth (proportions: 25/10/10)
# Value of 2 have moderate values for second harmonic, but higher third and fourth (proportions: 25/60/60)
# Value of 3 have lower values for second harmonic, but higher third and fourth (proportions: 10/60/60)
# Value of 4 have the same values for second, third and fourth harmonic (poportions 30/30/30)
# Values [1-4] (default: 3)

HBASSHARMTYPE=${config.hbassharmtype}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Minimum source frequency for Virtual Bass harmonics
# values [10-200] (default: 10)

HBASSHARMSRCFREQMIN=${config.hbassharmsrcfreqmin}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Maximum source frequency for Virtual Bass harmonics
# values [10-500] (default: 90)

HBASSHARMSRCFREQMAX=${config.hbassharmsrcfreqmax}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Minimum frequency on which Linear Gain will operate
# values [10-200] (default: 10)

HBASSHARMMIXFREQMIN=${config.hbassharmmixfreqmin}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Maximum frequency on which Linear Gain will operate
# values [10-500] (default: 90)

HBASSHARMMIXFREQMAX=${config.hbassharmmixfreqmax}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Maximum frequency on which Harmonics will be generated (based on SRC frequencies)
# values [60-500] (default: 240)

HBASSHARMGENFREQMAX=${config.hbassharmgenfreqmax}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# How strong Bass Harmonics boost you want?
# values [0-15] (default: 6)

HBASSHARMBOOST=${config.hbassharmboost}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Here you can set linear bass gain
# Values [0-20] (default: 7)

HBASSLINGAIN=${config.hbasslingain}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Here you can set strength of bass compressor
# Values [0-10] (default: 0)

HBASSCOMPSTRENGTH=${config.hbasscompstrength}

-----------------------------------

# Headphone Digital Volume booster
# How much in dB volume should be boosted?
# values [-15 to 15] (default and stock:0)

HVOLBOOST=${config.hvolboost}

-----------------------------------

# Headphone Digital Volume balance
# How much in dB volume should be balanced?
# -- -15 to -1 means less to right channel (left boost) --
# -- 0 means balanced volume between channels --
# -- 1 to 15 means less to left channel (right boost) --
# values [-15 to 15] (default and stock:0)

HVOLBALANCE=${config.hvolbalance}

-----------------------------------

# Dialog Enhancer. Should be turned on? or off?
# Value of 0 will turn off Dialog Enhancer
# Value of 1 will turn on Dialog Enhancer only for Movie profile
# Value of 2 will turn on Dialog Enhancer for every profile
# values [0-2] (default: 0)

HDE=${config.hde}

-----------------------------------

# This setting is working only with enabled Dialog Enhancer
# How strong Dialog Enhancer should be?
# values [1-10] (default: 6)

HDEA=${config.hdea}

-----------------------------------

# This setting is working only with enabled Dialog Enhancer
# How strong Dialog Enhancer ducking should be?
# values [0-10] (default: 0)

HDED=${config.hded}

-----------------------------------

# Choose how virtualizer setting should be set
# 0 - virtualizer will be off
# 1 - Virtualizer will be enabled in Movie preset and disabled in Music preset
# 2 - virtualizer will be enabled in every profile

HVIRTUALIZER=${config.hvirtualizer}

-----------------------------------

# This will set Virtualizer source distance 
# FOR SUPPORTED DOLBY
# values [4-100] (default: 40)

HVIRTDIST=${config.hvirtdist}

-----------------------------------

# Surround boost
# values [0-15] (default: 3)

HSURBOOST=${config.hsurboost}

-----------------------------------

# Headphone Advanced left-right Angle
# How wide (left-right angle) Virtualizer effect you want? 
# FOR SUPPORTED DOLBY
# values [45-90] (default: 90)

HADVIRTANGLE=${config.hadvirtangle}

-----------------------------------

# Which mode of Virtualizer effect you want?
# FOR SUPPORTED DOLBY
# Mode 1 means, Virtualizer is center oriented, soundscene is narrow.
# Mode 2 means, Virtualizer is much more expanded to sides.
# values [1 or 2] (default and stock: 2)

HVIRTMOD=${config.hvirtmod}

-----------------------------------

# Hadphone Advanced Virtualizer Renderer
# FOR ADVANCED USERS ONLY!
# THIS SETTING HAVE HUGE IMPACT ON VIRTUALIZER SOUNDSTAGE RENDERING
# FOR SUPPORTED DOLBY
#
# STOCK values are: 103,32568,11164,5090,0,3,3,3
# Some good and possible options:
# 160,32767,14379,7090,2,2,3,1
# 160,32767,16379,2065,0,3,3,0 - motorola spatializer 
# 103,32568,11164,5090,0,1,2,2 - xiaomi 15 spatializer
# 200,32767,16379,7090,3,3,3,1
# 200,32568,15164,8090,1,2,2,1 (one of my favorite)
# 200,32568,15164,8090,1,2,3,1 (also one of my favorite)
# 360,65535,8192,4096,0,3,2,2 (one of my favorite and currently used)
# I encourage to experiment but be careful with modifying it ^^

HADVIRTREND=${config.hadvirtrend}

-----------------------------------

# Which value of Virtualizer height filter effect you want?
# Value of 0 means, Virtualizer height filter is off.
# Value of 1 means, Virtualizer height filter is on, sound should be slightly elevated.
# Value of 2 means, Virtualizer height filter is on, sound should be more elevated.
# values [0-2] (default and stock: 1)

HHEIGHTFILTER=${config.hheightfilter}

-----------------------------------

# Should Volume Leveler be turned on or off? 
# values [ON or OFF] (default and stock: OFF)

HLEVELER=${config.hleveler}

-----------------------------------

# How strong volume boost with volume leveler should be? 
# values [0-10] (default: 3)

HLEVSTR=${config.hlevstr}

-----------------------------------

# This setting is working when Volume Leveler
# How fast HLEVELER should react?
# values [0-10] (default: 0)

HLEVAMOUNT=${config.hlevamount}

-----------------------------------

# FOR A BIT MORE ADVANCED USERS!
# This setting is working when Volume Leveler
# How aggressive volume leveler should be in attenuation peaks?
# values [1-10] (default and stock: 6)

HLEVTARGETIN=${config.hlevtargetin}

-----------------------------------

# FOR A BIT MORE ADVANCED USERS!
# This setting is working when Volume Leveler
# How aggressive volume leveler should be in modifying signal?
# values [1-10] (default and stock: 6)

HLEVTARGETOUT=${config.hlevtargetout}

-----------------------------------

# FOR A BIT MORE ADVANCED USERS!
# Regulator applies restrictions to overly gained signal
# values [ON or OFF] (default: ON)

HREGULATOR=${config.hregulator}

-----------------------------------

# FOR A BIT MORE ADVANCED USERS!
# Regulator overdrive let enhance signal above regulator restrictions
# values [0-10] (default: 0 stock: 0)

HREGOVERDRIVE=${config.hregoverdrive}

-----------------------------------

# How hard regulator should try to preserve timbre?
# values [0-10] (default and stock: 3)

HTIMBRE=${config.htimbre}

-----------------------------------

# To which samplerate should dolby tune itself?
# possible values [44100,48000,88200,96000,176400,192000,352800,384000] 
# (default and stock: 48000)

HTUNEDRATE=${config.htunedrate}

-----------------------------------

# Select amount of output channels
# values [1-8] (default and stock: 2)

H_OUTPUT_CHANNELS=${config.h_output_channels}

-----------------------------------
#########################
### SPEAKER SECTION ###
#########################
-----------------------------------

# Do you want to modify your Speaker experience?
# Values [YES or NO] (default YES)

SPEAKERTUNING=${config.speakertuning}

-----------------------------------

# Which Intelligent EQ preset you want? 
# (values B - Balanced, D - Detailed, W - Warm, N - Disabled IEQ)
# You can also create your own profile with targets specified below
# (C - Custom new ieq profile, CD - Custom new ieq profile (Override Detailed))
# (default and stock: B)

SIEQ=${config.sieq}

#INTELLIGENT EQUALIZER
# Values [-500 to 500]
# SIEQ must be set to "C" or "CD" to freely change values

SIET_1=${parseFloat(config.siet_1)}
SIET_2=${parseFloat(config.siet_2)}
SIET_3=${parseFloat(config.siet_3)}
SIET_4=${parseFloat(config.siet_4)}
SIET_5=${parseFloat(config.siet_5)}
SIET_6=${parseFloat(config.siet_6)}
SIET_7=${parseFloat(config.siet_7)}
SIET_8=${parseFloat(config.siet_8)}
SIET_9=${parseFloat(config.siet_9)}
SIET_10=${parseFloat(config.siet_10)}
SIET_11=${parseFloat(config.siet_11)}
SIET_12=${parseFloat(config.siet_12)}
SIET_13=${parseFloat(config.siet_13)}
SIET_14=${parseFloat(config.siet_14)}
SIET_15=${parseFloat(config.siet_15)}
SIET_16=${parseFloat(config.siet_16)}
SIET_17=${parseFloat(config.siet_17)}
SIET_18=${parseFloat(config.siet_18)}
SIET_19=${parseFloat(config.siet_19)}
SIET_20=${parseFloat(config.siet_20)}

-----------------------------------

# How strong Intelligent EQ should be? 
# values [1-20] (default: 6)

SIEQSTR=${config.sieqstr}

-----------------------------------

# Headphone Equalizer Preset
# Values [flat, bass_emphasis, treble_emphasis, vocal_clarity, custom] (default: flat)

SEQPRESET=${config.seqpreset}

-----------------------------------

#EQUALIZER
# Values [-12 to 12] (default: 0 for all frequencies)
# HEQPRESET must be set to custom to freely change values

SEQ_1=${parseFloat(config.seq_1)}
SEQ_2=${parseFloat(config.seq_2)}
SEQ_3=${parseFloat(config.seq_3)}
SEQ_4=${parseFloat(config.seq_4)}
SEQ_5=${parseFloat(config.seq_5)}
SEQ_6=${parseFloat(config.seq_6)}
SEQ_7=${parseFloat(config.seq_7)}
SEQ_8=${parseFloat(config.seq_8)}
SEQ_9=${parseFloat(config.seq_9)}
SEQ_10=${parseFloat(config.seq_10)}
SEQ_11=${parseFloat(config.seq_11)}
SEQ_12=${parseFloat(config.seq_12)}
SEQ_13=${parseFloat(config.seq_13)}
SEQ_14=${parseFloat(config.seq_14)}
SEQ_15=${parseFloat(config.seq_15)}
SEQ_16=${parseFloat(config.seq_16)}
SEQ_17=${parseFloat(config.seq_17)}
SEQ_18=${parseFloat(config.seq_18)}
SEQ_19=${parseFloat(config.seq_19)}
SEQ_20=${parseFloat(config.seq_20)}

-----------------------------------

# Bass enhancer (BE) or Virtual Bass (VB)?
# values [BE or VB] (default: Virtual Bass)

SRENDERBASS=${config.srenderbass}

-----------------------------------

# This parameter work ONLY with Bass Enhancer
# How strong Bass Enhancer boost you want?
# values [0-15] (default: 6)

SBASSBOOST=${config.sbassboost}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Each value will result with different virtual bass sound (proportions: second/third/fourth harmonic)
# Value of 1 have higher values for second harmonic than third and fourth (proportions: 25/10/10)
# Value of 2 have moderate values for second harmonic, but higher third and fourth (proportions: 25/60/60)
# Value of 3 have lower values for second harmonic, but higher third and fourth (proportions: 10/60/60)
# Value of 4 have the same values for second, third and fourth harmonic (poportions 30/30/30)
# Values [1-4] (default: 3)

SBASSHARMTYPE=${config.sbassharmtype}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# How strong Bass Harmonics boost you want?
# values [0-15] (default: 5)

SBASSHARMBOOST=${config.sbassharmboost}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Here you can set linear bass gain
# Values [0-15] (default: 5)

SBASSLINGAIN=${config.sbasslingain}

-----------------------------------

# This parameter work ONLY with Virtual Bass
# Here you can set strength of bass compressor
# Values [0-10] (default: 0)

SBASSCOMPSTRENGTH=${config.sbasscompstrength}

-----------------------------------

# Speaker Digital Volume booster
# How much in dB volume should be boosted?
# values [-15 to 15] (default and stock:0)

SVOLBOOST=${config.svolboost}

-----------------------------------

# Dialog Enhancer. Should be turned on? or off?
# Value of 0 will turn off Dialog Enhancer
# Value of 1 will turn on Dialog Enhancer only for Movie profile
# Value of 2 will turn on Dialog Enhancer for every profile
# values [0-2] (default: 0)

SDE=${config.sde}

-----------------------------------

# This setting is working only with enabled Dialog Enhancer
# How strong Dialog Enhancer should be?
# values [1-10] (default: 6)

SDEA=${config.sdea}

-----------------------------------

# This setting is working only with enabled Dialog Enhancer
# How strong Dialog Enhancer ducking should be?
# values [0-10] (default: 0)

SDED=${config.sded}

-----------------------------------

# Choose how virtualizer setting should be set
# 0 - virtualizer will be off
# 1 - Virtualizer will be enabled in Movie preset and disabled in Music preset
# 2 - virtualizer will be enabled in every profile

SVIRTUALIZER=${config.svirtualizer}

-----------------------------------

# Surround boost
# values [0-15] (default: 3)

SSURBOOST=${config.ssurboost}

-----------------------------------

# Which mode of Virtualizer effect you want?
# FOR SUPPORTED DOLBY
# Mode 1 means, Virtualizer is center oriented, soundscene is narrow.
# Mode 2 means, Virtualizer is much more expanded to sides.
# values [1 or 2] (default and stock: 2)

SVIRTMOD=${config.svirtmod}

-----------------------------------

# Speaker Advanced Virtualizer Renderer
# FOR ADVANCED USERS ONLY!
# THIS SETTING HAVE HUGE IMPACT ON VIRTUALIZER SOUNDSTAGE RENDERING
# FOR SUPPORTED DOLBY
#
# STOCK values are: 103,32568,11164,5090,0,3,3,3
# Some good and possible options:
# 160,32767,14379,7090,2,2,3,1
# 160,32767,16379,2065,0,3,3,0 - motorola spatializer 
# 103,32568,11164,5090,0,1,2,2 - xiaomi 15 spatializer
# 200,32767,16379,7090,3,3,3,1
# 200,32568,15164,8090,1,2,2,1 (one of my favorite)
# 200,32568,15164,8090,1,2,3,1 (also one of my favorite)
# 360,65535,8192,4096,0,3,2,2 (one of my favorite and currently used)
# I encourage to experiment but be careful with modifying it ^^

SADVIRTREND=${config.sadvirtrend}

-----------------------------------

# Should Volume Leveler be turned on or off? 
# values [ON or OFF] (default and stock: OFF)

SLEVELER=${config.sleveler}

-----------------------------------
# How strong volume boost with volume leveler should be? 
# values [0-10] (default: 3)

SLEVSTR=${config.slevstr}

-----------------------------------

# This setting is working when Volume Leveler
# How fast SLEVELER should react?
# values [0-10] (default: 0)

SLEVAMOUNT=${config.slevamount}

-----------------------------------

# FOR A BIT MORE ADVANCED USERS!
# This setting is working when Volume Leveler
# How aggressive volume leveler should be in attenuation peaks?
# values [1-10] (default and stock: 6)

SLEVTARGETIN=${config.slevtargetin}

-----------------------------------

# FOR A BIT MORE ADVANCED USERS!
# This setting is working when Volume Leveler
# How aggressive volume leveler should be in modifying signal?
# values [1-10] (default and stock: 6)

SLEVTARGETOUT=${config.slevtargetout}

-----------------------------------

# How hard regulator should try to preserve timbre?
# values [0-10] (default and stock: 3)

STIMBRE=${config.stimbre}

-----------------------------------

# To which samplerate should dolby tune itself?
# possible values [44100,48000,88200,96000,176400,192000,352800,384000] 
# (default and stock: 48000)

STUNEDRATE=${config.stunedrate}

-----------------------------------

# Select amount of output channels
# values [1-8] (default and stock: 2)

S_OUTPUT_CHANNELS=${config.s_output_channels}

-----------------------------------
`;
};
