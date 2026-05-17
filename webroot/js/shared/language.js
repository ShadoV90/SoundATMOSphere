import { state } from './state.js';
import { actionLog } from './utils.js';
import { updateOutput, updateDefaultValuesDisplay } from '../view/renderer.js';

export const convertToLanguageNumerals = (value, lang = 'en') => {
	
	const map = state.translations[lang]?.numerals || state.translations.en?.numerals;

	if (!map || map.length !== 10) {
		return value.toString();
	}

	const result = value.toString().replace(/\d/g, digit => map[parseInt(digit, 10)]);
	return result;
};

export const convertFromLanguageNumerals = (value, lang = 'en') => {
	const map = state.translations[lang]?.numerals || state.translations.en?.numerals;
	if (!map || map.length !== 10) {
		return value.toString();
	}
	const reverseMap = Object.fromEntries(map.map((num, i) => [num, i.toString()]));
	return value
		.toString()
		.split('')
		.map(char => reverseMap[char] || char)
		.join('');
};

export const populateLanguageSelect = () => {
	const languageSelect = state.domCache.languageSelect;
	if (!languageSelect) {
		console.warn('Language select element not found in DOM cache');
		return;
	}
	languageSelect.innerHTML = '';
	Object.keys(state.translations).forEach(langCode => {
		const option = document.createElement('option');
		option.value = langCode;
		option.textContent = state.translations[langCode].language_name || langCode.toUpperCase();
		languageSelect.appendChild(option);
	});
	languageSelect.value = localStorage.getItem('selectedLanguage') || 'en';
	languageSelect.addEventListener('change', (event) => {
		const newLang = event.target.value;
		localStorage.setItem('selectedLanguage', newLang);
		switchLanguage(newLang);
	});
};

export const loadTranslations = async () => {
	try {
		const response = await fetch('translations.json');
		if (!response.ok) {
			throw new Error(`HTTP error! status: ${response.status}`);
		}
		const newTranslations = await response.json();
		state.translations = newTranslations;
		
		const lang = localStorage.getItem('selectedLanguage') || 'en';
		actionLog(state.translations[lang]?.translations_loaded || 'Translations loaded');
		populateLanguageSelect();
		switchLanguage(lang);
	} catch (error) {
		actionLog(`Error loading translations: ${error.message}. UI may not be translated.`);
		state.translations = { en: { language_name: "English (fallback)", numerals: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] } };
		populateLanguageSelect();
		switchLanguage('en');
	}
};

export const switchLanguage = (lang) => {
	if (!state.translations[lang]) {
		lang = 'en';
	}
	state.currentLanguage = lang;
	const translations = state.translations[lang];
	if (!translations) {
		return;
	}
	
	actionLog(`${translations['language_switched_to'] || 'Language switched to'} ${translations.language_name}`);
	document.title = translations['title'] || 'Dolby Tuning DIY';
	document.querySelectorAll('[data-lang-key]').forEach(el => {
		if (el.tagName !== 'OPTION' && el.tagName !== 'SELECT') {
			const key = el.getAttribute('data-lang-key');
			el.textContent = translations[key] || `[${key}]`;
		}
	});

	const selectsToTranslate = [
		'hieq', 'hieqCustomBase', 'heqpreset', 'hbassharmtype', 'hde', 'htimbre', 'hvirtualizer', 'hvirtmod',
		'hheightfilter', 'hadvirtrend', 'htunedrate', 'h_output_channels',
		'sieq', 'sbassharmtype', 'sde', 'stimbre', 'svirtualizer', 'svirtmod', 'sadvirtrend',
		'stunedrate', 's_output_channels'
	];
	
	const numericOptionsSelects = ['h_output_channels', 's_output_channels'];

	selectsToTranslate.forEach(id => {
		const select = state.domCache[id];
		if (!select) return;

		const previouslySelectedValue = select.value;
		const optionsData = [];
		select.querySelectorAll('option').forEach(option => {
			optionsData.push({ value: option.value, key: option.getAttribute('data-lang-key') });
		});
		select.innerHTML = '';

		optionsData.forEach(data => {
			const newOption = document.createElement('option');
			newOption.value = data.value;

			if (data.key) {
				newOption.textContent = translations[data.key] || `[${data.key}]`;
				newOption.setAttribute('data-lang-key', data.key);
			} else if (numericOptionsSelects.includes(id)) {
				console.log(`DEBUG (pętla select): Przetwarzam opcję numeryczną dla "${id}", wartość: "${data.value}"`);
				newOption.textContent = convertToLanguageNumerals(data.value, lang);
			} else {
				newOption.textContent = data.value;
			}
			select.appendChild(newOption);
		});
		select.value = previouslySelectedValue;
	});

	document.querySelectorAll('.toggle-btn').forEach(btn => {
		const state = btn.getAttribute('data-state');
		if (btn.id === 'hrenderbass' || btn.id === 'srenderbass') {
			btn.textContent = state === 'true' ? (translations['bass_enhancer'] || 'BE') : (translations['virtual_bass'] || 'VB');
		} else {
			if (state === 'true') {
				 btn.textContent = btn.id === 'headphonetuning' || btn.id === 'speakertuning' 
					? (translations['yes'] || 'YES') 
					: (translations['on'] || 'ON');
			} else {
				 btn.textContent = btn.id === 'headphonetuning' || btn.id === 'speakertuning' 
					? (translations['no'] || 'NO')
					: (translations['off'] || 'OFF');
			}
		}
	});

	updateDefaultValuesDisplay();
	updateOutput();
};