
import { state } from '../shared/state.js';
import { getDomElement } from '../shared/dom.js';
import { convertToLanguageNumerals } from '../shared/language.js';
import { updateOutput } from '../view/renderer.js';

export const initVolumeLeveler = () => {
	const lang = state.domCache.languageSelect?.value || 'en';

	// Headphone volume leveler toggle
	const hLeveler = getDomElement('hleveler');
	if (hLeveler) {
		hLeveler.addEventListener('click', () => {
			const isOn = hLeveler.getAttribute('data-state') === 'true';
			hLeveler.setAttribute('data-state', !isOn);
			hLeveler.textContent = !isOn ? state.translations[lang]['on'] : state.translations[lang]['off'];
			hLeveler.classList.toggle('active', !isOn);
			updateOutput();
		});
	}

	// Speaker volume leveler toggle
	const sLeveler = getDomElement('sleveler');
	if (sLeveler) {
		sLeveler.addEventListener('click', () => {
			const isOn = sLeveler.getAttribute('data-state') === 'true';
			sLeveler.setAttribute('data-state', !isOn);
			sLeveler.textContent = !isOn ? state.translations[lang]['on'] : state.translations[lang]['off'];
			sLeveler.classList.toggle('active', !isOn);
			updateOutput();
		});
	}

	// Sliders
	const sliders = ['hlevstr', 'hlevamount', 'hlevtargetin', 'hlevtargetout', 'slevstr', 'slevamount', 'slevtargetin', 'slevtargetout'];
	sliders.forEach(id => {
		const slider = getDomElement(id);
		if (slider) {
			slider.addEventListener('input',() => {
				const valueDisplay = getDomElement(`${id}-value`);
				if (valueDisplay) {
					valueDisplay.textContent = convertToLanguageNumerals(slider.value, lang);
				}
				updateOutput();
			});
		}
	});
};