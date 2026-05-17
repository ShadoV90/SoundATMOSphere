import { state } from '../shared/state.js';
import { getDomElement } from '../shared/dom.js';
import { actionLog } from '../shared/utils.js';
import { saveConfig, applyTuning, setSimpleModeDefaults } from '../config/configservice.js';
import { resetToDefault, updateOutput, updateDefaultValuesDisplay } from '../view/renderer.js';
import { bassVisibility } from '../features/bass.js';

// Setup common events (load/save/apply/reset)
export const setupCommonEvents = () => {
	const loadBtn = getDomElement('loadConfig');
	if (loadBtn) loadBtn.addEventListener('click', loadConfig);
	
	const saveBtn = getDomElement('saveConfig');
	if (saveBtn) saveBtn.addEventListener('click', saveConfig);
	
	const applyBtn = getDomElement('applyTuning');
	if (applyBtn) applyBtn.addEventListener('click', applyTuning);
	
	const resetBtn = getDomElement('resetToDefault');
	if (resetBtn) resetBtn.addEventListener('click', resetToDefault);
	
	// UI mode toggles
	const simpleMode = getDomElement('simple-mode');
	const expertMode = getDomElement('expert-mode');
	if (simpleMode) simpleMode.addEventListener('click', () => applyUIMode(true));
	if (expertMode) expertMode.addEventListener('click', () => applyUIMode(false));
};

export const applyUIMode = async (isSimple) => {
	const lang = state.domCache.languageSelect?.value || 'en';
	state.isSimpleMode = isSimple;
	localStorage.setItem('uiMode', isSimple ? 'simple' : 'expert');
	
	// Toggle classes for simple/expert elements
	const simpleMode = getDomElement('simple-mode');
	const expertMode = getDomElement('expert-mode');
	if (simpleMode) simpleMode.classList.toggle('active', isSimple);
	if (expertMode) expertMode.classList.toggle('active', !isSimple);
	document.body.classList.toggle('simple-mode', isSimple);
	document.body.classList.toggle('expert-mode', !isSimple);
	
	if (isSimple) {
		setSimpleModeDefaults();
	} else {
		// Enable bass toggles in expert mode if harm is supported
		const hBassToggle = getDomElement('hrenderbass');
		const sBassToggle = getDomElement('srenderbass');
		if (hBassToggle && state.supportedFeatures.harm) {
			hBassToggle.disabled = false;
		}
		if (sBassToggle && state.supportedFeatures.harm) {
			sBassToggle.disabled = false;
		}
	}

	// Update visibility and other elements
	bassVisibility('headphone', 'hrenderbass', lang);
	bassVisibility('speaker', 'srenderbass', lang);
	updateOutput();
	updateDefaultValuesDisplay();
	actionLog(`Switched to ${isSimple ? 'Simple' : 'Expert'} mode`);
};