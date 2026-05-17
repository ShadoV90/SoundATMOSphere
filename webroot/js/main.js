import { state } from './shared/state.js';
import { cacheDomElements, getDomElement } from './shared/dom.js';
import { loadTranslations } from './shared/language.js';
import { actionLog } from './shared/utils.js';
import { loadConfig, checkFeatureSupport, ensureDefaultValuesLoaded } from './config/configservice.js';
import { setupCommonEvents, applyUIMode } from './events/events.js';
import { initBass } from './features/bass.js';
import { initDialogEnhancer } from './features/dialogenhancer.js';
import { initEqualizer } from './features/equalizer.js';
import { initTuningToggles } from './features/tuningToggles.js'; 
import { initHpSpToggle } from './features/hpsp-toggle.js'; 
import { initEndpointSettings } from './features/endpoint.js';
import { initIeq } from './features/ieq.js';
import { initMediaIntelligence } from './features/mediaintelligence.js';
import { initRegulator } from './features/regulator.js';
import { initVirtualizer, virtListeners } from './features/virtualizer.js';
import { initVolBoost } from './features/volboost.js';
import { initVolumeLeveler } from './features/volumeleveler.js';
import { updateOutput, updateDefaultValuesDisplay } from './view/renderer.js';

document.addEventListener('DOMContentLoaded', async () => {
	try {
		cacheDomElements();
		getDomElement();
		await loadTranslations();
		setupCommonEvents();
		virtListeners();
		await checkFeatureSupport();
		ensureDefaultValuesLoaded(); 
		
		if (state.isSimpleMode === undefined) {
			state.isSimpleMode = true;
		}

		const storedUIMode = localStorage.getItem('uiMode');
		if (storedUIMode) {
			actionLog(`Loading stored UI mode: ${storedUIMode}`);
			state.isSimpleMode = storedUIMode === 'simple';
		} else {
			actionLog('No stored UI mode found. Defaulting to simple mode.');
		}
		
		await applyUIMode(state.isSimpleMode);
		initTuningToggles();
		initHpSpToggle();
		initBass();
		initDialogEnhancer();
		initEqualizer();
		initIeq();
		initMediaIntelligence();
		initRegulator();
		initVirtualizer();
		initVolBoost();
		initVolumeLeveler();
		initEndpointSettings();
		await loadConfig();
		updateOutput();
		updateDefaultValuesDisplay();
	} catch (error) {
		actionLog(`Initialization error: ${error.message}`);
		console.error('CRITICAL INITIALIZATION ERROR:', error);
	}
});