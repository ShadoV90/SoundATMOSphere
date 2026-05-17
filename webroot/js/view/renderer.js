import { state } from '../shared/state.js';
import { getDomElement } from '../shared/dom.js';
import { convertToLanguageNumerals } from '../shared/language.js';
import { generateConfigString, configMap, visibilityMap, defaultValues, translationMaps } from '../config/configmodel.js';
import { isNumeric } from '../shared/utils.js';
import { bassVisibility } from '../features/bass.js';

export const updateOutputVisibility = () => {
	const outputSection = getDomElement('output-section');
	if (!outputSection) return;

	let isEnabled = false;
	if (state.currentSection === 'headphone') {
		const hpToggle = getDomElement('headphonetuning');
		isEnabled = hpToggle ? hpToggle.getAttribute('data-state') === 'true' : false;
	} else if (state.currentSection === 'speaker') {
		const spToggle = getDomElement('speakertuning');
		isEnabled = spToggle ? spToggle.getAttribute('data-state') === 'true' : false;
	}

	outputSection.style.display = isEnabled ? '' : 'none';
};

export const toggleVisibility = (section, toggleId, featureKey = null) => {
	const toggle = state.domCache[toggleId];
	if (!toggle) {
		console.log(`toggleVisibility: Toggle ${toggleId} not found in domCache`);
		if (featureKey) {
		}
		return; 
	}
	const isSimpleMode = document.body.classList.contains('simple-mode');
	const isSimple = isSimpleMode ? false : toggle.getAttribute('data-state') === 'false';
	
	for (const [key, { id, showWhen }] of Object.entries(visibilityMap[section])) {
		const container = state.domCache[id];
		if (container) {
			const isExpertOnly = container.classList.contains('expert-only');
			const shouldShow = showWhen(isSimpleMode, isSimple, state.supportedFeatures);
			const displayValue = shouldShow && (!isSimpleMode || !isExpertOnly) ? 'block' : 'none';
			container.style.display = displayValue;
			container.style.removeProperty('display');
			container.style.display = displayValue;
			if (displayValue === 'block') {
				container.classList.add('visible');
				container.querySelectorAll('.slider-container').forEach(slider => {
					slider.style.removeProperty('display');
					slider.style.display = 'block';
					const input = slider.querySelector('input[type="range"]');
					if (input) {
						input.style.removeProperty('display');
						input.style.display = 'inline-block';
					}
				});
			} else {
				container.classList.remove('visible');
				container.querySelectorAll('.slider-container').forEach(slider => {
					slider.style.removeProperty('display');
					slider.style.display = 'none';
					const input = slider.querySelector('input[type="range"]');
					if (input) {
						input.style.removeProperty('display');
						input.style.display = 'none';
					}
				});
			}
		}
	}
	updateOutput();
};

export const updateOutput = () => {
	const configString = generateConfigString();
	const outputElement = state.domCache['output'];
	if (outputElement) {
		outputElement.value = configString;
	} else {
		console.warn('Output element (id="output") not found.');
	}
};

export const resetToDefault = () => {
	const lang = state.domCache.languageSelect ? state.domCache.languageSelect.value : 'en';
	for (const [key, value] of Object.entries(defaultValues)) {
		const element = state.domCache[key.toLowerCase()];
		if (!element) continue;
		if (element.type === 'range') {
			element.value = value;
			const valueDisplay = state.domCache[`${key.toLowerCase()}-value`] || element.closest('.slider-container')?.querySelector('.slider-value');
			if (valueDisplay) {
				valueDisplay.textContent = convertToLanguageNumerals(value, lang) + (key.startsWith('HEQ_') ? ' dB' : '');
			}
		} else if (element.tagName === 'SELECT') {
			element.value = value;
			if (key === 'HADVIRTREND') checkCustom(element, 'customInput');
			if (key === 'SADVIRTREND') checkCustom(element, 'scustomInput');
		} else if (element.classList.contains('toggle-btn')) {
			const isOn = value === 'ON' || value === 'YES' || value === 'BE';
			element.setAttribute('data-state', isOn);
			element.textContent = key === 'HRENDERBASS' || key === 'SRENDERBASS'
				? (isOn ? state.translations[lang]['bass_enhancer'] : state.translations[lang]['virtual_bass'])
				: (isOn ? state.translations[lang][key === 'SPEAKERTUNING' || key === 'HEADPHONETUNING' ? 'yes' : 'on'] : state.translations[lang][key === 'SPEAKERTUNING' || key === 'HEADPHONETUNING' ? 'no' : 'off']);
			element.classList.toggle('active', isOn);
		}
	}
	state.hieqCustomValues = '150,142,188,216,189,195,202,199,210,225,230,236,235,235,214,165,112,49,-24,-217';
	updateHieqInputs(state.domCache.hieq?.value || 'B', lang);
	bassVisibility('headphone', 'hrenderbass');
	bassVisibility('speaker', 'srenderbass');
	updateRendererValues();
	updateSpeakerRendererValues();
	updateOutput();
	updateDefaultValuesDisplay();
	actionLog(state.translations[lang]['reset_to_default']);
};

export const updateDefaultValuesDisplay = () => {
	const lang = state.domCache.languageSelect?.value || 'en';
	const defaultLabel = state.translations[lang]?.default || 'Default';

	for (const [key, { default: defaultValue, type }] of Object.entries(configMap)) {
		const element = state.domCache[`${key.toLowerCase()}-default`];
		if (!element) {
			console.warn(`No default display element found for key: ${key}`);
			continue;
		}

		let translatedValue = defaultValue;

		// Handle specific parameters with translation maps
		if (['hrenderbass', 'srenderbass'].includes(key.toLowerCase())) {
			translatedValue = state.translations[lang][defaultValue === 'BE' ? 'bass_enhancer' : 'virtual_bass'] || defaultValue;
		} else if (['hadvirtrend', 'sadvirtrend'].includes(key.toLowerCase())) {
			// Check if the default value is in the advVirtRend translation map
			const advVirtRendKey = translationMaps.advVirtRend[defaultValue] || 'custom';
			if (advVirtRendKey !== 'custom') {
				translatedValue = state.translations[lang][advVirtRendKey] || defaultValue;
			} else {
				// Fallback to numerical values if custom or not found in translation map
				translatedValue = defaultValue.split(',').map(val => convertToLanguageNumerals(val.trim(), lang)).join(',');
			}
		} else if (['headphonetuning', 'speakertuning', 'hleveler', 'sleveler', 'hregulator', 'dolbymi'].includes(key.toLowerCase())) {
			translatedValue = state.translations[lang][defaultValue.toLowerCase()] || defaultValue;
		} else if (['hvirtmod', 'svirtmod'].includes(key.toLowerCase())) {
			translatedValue = state.translations[lang][translationMaps.virtMod[defaultValue]] || defaultValue;
		} else if (['hde', 'sde', 'hvirtualizer', 'svirtualizer'].includes(key.toLowerCase())) {
			translatedValue = state.translations[lang][translationMaps.dialogEnhancer[defaultValue]] || defaultValue;
		} else if (['hieq', 'sieq'].includes(key.toLowerCase())) {
			translatedValue = state.translations[lang][translationMaps.ieq[defaultValue]] || defaultValue;
		} else if (['hheightfilter'].includes(key.toLowerCase())) {
			translatedValue = state.translations[lang][translationMaps.heightFilter[defaultValue]] || defaultValue;
		} else if (['htimbre', 'stimbre'].includes(key.toLowerCase())) {
			translatedValue = state.translations[lang][translationMaps.timbre[defaultValue]] || defaultValue;
		} else if (key.startsWith('HEQ_')) {
			translatedValue = convertToLanguageNumerals(defaultValue, lang) + ' dB';
		} else {
			// Numeric parameters
			translatedValue = isNumeric(defaultValue) ? convertToLanguageNumerals(defaultValue, lang) : defaultValue;
		}

		element.textContent = `(${defaultLabel}: ${translatedValue})`;
	}
};