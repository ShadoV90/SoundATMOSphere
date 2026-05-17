import { state } from '../shared/state.js';
import { getDomElement } from '../shared/dom.js';
import { updateOutput, updateOutputVisibility } from '../view/renderer.js';

const toggleGroupSections = (groupElement, toggleSectionId, isEnabled) => {
	if (!groupElement) return;

	const sections = groupElement.querySelectorAll('.section');
	
	sections.forEach(section => {
		if (section.id !== toggleSectionId) {
			section.style.display = isEnabled ? '' : 'none';
		}
	});
};


export const initHpSpToggle = () => {
	const lang = state.domCache.languageSelect?.value || 'en';
	const hpGroup = getDomElement('headphone-group');
	const spGroup = getDomElement('speaker-group');
	const hpToggle = getDomElement('headphonetuning');

	if (hpToggle) {
		hpToggle.addEventListener('click', () => {
			const isOn = hpToggle.getAttribute('data-state') === 'true';
			const newState = !isOn;

			hpToggle.setAttribute('data-state', newState);
			hpToggle.textContent = newState ? state.translations[lang]['yes'] : state.translations[lang]['no'];
			hpToggle.classList.toggle('active', newState);

			toggleGroupSections(hpGroup, 'headphone-tuning-section', newState);

			updateOutput();
		updateOutputVisibility();
		});

		const initialState = hpToggle.getAttribute('data-state') === 'true';
		toggleGroupSections(hpGroup, 'headphone-tuning-section', initialState);
	}

	const spToggle = getDomElement('speakertuning');
	if (spToggle) {
		spToggle.addEventListener('click', () => {
			const isOn = spToggle.getAttribute('data-state') === 'true';
			const newState = !isOn;

			spToggle.setAttribute('data-state', newState);
			spToggle.textContent = newState ? state.translations[lang]['yes'] : state.translations[lang]['no'];
			spToggle.classList.toggle('active', newState);

			toggleGroupSections(spGroup, 'speaker-tuning-section', newState);

			updateOutput();
		updateOutputVisibility();
		});

		const initialState = spToggle.getAttribute('data-state') === 'true';
		toggleGroupSections(spGroup, 'speaker-tuning-section', initialState);
	}
	updateOutputVisibility();
};