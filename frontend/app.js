// STATE
let selectedProfession = '';
let selectedTopic = '';

// DOM Elements
const screenProfession = document.getElementById('screen-profession');
const screenTopic = document.getElementById('screen-topic');
const screenResults = document.getElementById('screen-results');
const loadingOverlay = document.getElementById('loading-overlay');

const professionRadios = document.querySelectorAll('.profession-radio');
const customProfessionInput = document.getElementById('custom-profession');
const btnProfessionContinue = document.getElementById('btn-profession-continue');

const topicInput = document.getElementById('topic-input');
const displayProfession = document.getElementById('display-profession');
const btnBackToProfession = document.getElementById('btn-back-to-profession');
const btnEditProfession = document.getElementById('btn-edit-profession');
const btnAnalyze = document.getElementById('btn-analyze');
const topicSuggestions = document.querySelectorAll('.topic-suggestion');

const btnBackToTopic = document.getElementById('btn-back-to-topic');
const btnAdjustRole = document.getElementById('btn-adjust-role');


// NAVIGATION FUNCS
function showScreen(screenEl) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    screenEl.classList.add('active');
}

function resetApp() {
    selectedProfession = '';
    selectedTopic = '';
    
    // Clear forms
    professionRadios.forEach(r => r.checked = false);
    customProfessionInput.value = '';
    topicInput.value = '';
    
    validateProfession();
    validateTopic();
    
    showScreen(screenProfession);
}


// SCREEN 1: PROFESSION LOGIC
function validateProfession() {
    const radioSelected = Array.from(professionRadios).some(r => r.checked);
    const customFilled = customProfessionInput.value.trim().length > 0;
    
    if (radioSelected || customFilled) {
        btnProfessionContinue.disabled = false;
    } else {
        btnProfessionContinue.disabled = true;
    }
}

professionRadios.forEach(radio => {
    radio.addEventListener('change', () => {
        // clear custom if radio selected
        if (radio.checked) customProfessionInput.value = '';
        validateProfession();
    });
});

customProfessionInput.addEventListener('input', () => {
    // clear radios if custom filled
    if (customProfessionInput.value.length > 0) {
        professionRadios.forEach(r => r.checked = false);
    }
    validateProfession();
});

btnProfessionContinue.addEventListener('click', () => {
    const checkedRadio = Array.from(professionRadios).find(r => r.checked);
    selectedProfession = checkedRadio ? checkedRadio.value : customProfessionInput.value.trim();
    
    // Update next screen State
    displayProfession.textContent = selectedProfession;
    
    showScreen(screenTopic);
    setTimeout(() => topicInput.focus(), 100);
});


// SCREEN 2: TOPIC LOGIC
function validateTopic() {
    selectedTopic = topicInput.value.trim();
    btnAnalyze.disabled = selectedTopic.length === 0;
}

topicInput.addEventListener('input', validateTopic);

topicSuggestions.forEach(btn => {
    btn.addEventListener('click', () => {
        topicInput.value = btn.textContent.trim();
        validateTopic();
    });
});

function goBackToProfession() {
    showScreen(screenProfession);
}
btnBackToProfession.addEventListener('click', goBackToProfession);
btnEditProfession.addEventListener('click', goBackToProfession);

btnAnalyze.addEventListener('click', async () => {
    selectedTopic = topicInput.value.trim();
    if (!selectedTopic || !selectedProfession) return;

    // Show loading
    loadingOverlay.style.display = 'flex';

    try {
        const response = await fetch('/analyze-topic', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                profession: selectedProfession,
                topic: selectedTopic
            })
        });

        if (!response.ok) {
            throw new Error(`API returned ${response.status}`);
        }

        const data = await response.json();
        renderResults(data);
        showScreen(screenResults);
        
    } catch (error) {
        alert('Failed to analyze topic. Ensure backend is running. Details: ' + error.message);
        console.error(error);
    } finally {
        loadingOverlay.style.display = 'none';
    }
});


// SCREEN 3: RESULTS LOGIC
function formatText(text) {
    // Basic Markdown formatting for display (bolding **text**)
    return text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
               .replace(/\n/g, '<br/>');
}

function renderResults(data) {
    document.getElementById('result-topic-title').textContent = selectedTopic;
    document.getElementById('result-profession-display').textContent = selectedProfession;
    
    // Complexity Badge
    const compText = document.getElementById('complexity-text');
    const compBadge = document.getElementById('complexity-badge');
    compText.textContent = data.complexity;
    
    // reset classes
    compBadge.className = "flex h-8 shrink-0 items-center justify-center gap-x-2 rounded-full pl-3 pr-4 ring-1";
    if (data.complexity === "Basic") {
        compBadge.classList.add("bg-green-500/10", "dark:bg-green-400/20", "ring-green-500/20");
        compText.className = "text-green-700 dark:text-green-300 text-sm font-semibold leading-normal";
    } else if (data.complexity === "Advanced") {
        compBadge.classList.add("bg-red-500/10", "dark:bg-red-400/20", "ring-red-500/20");
        compText.className = "text-red-700 dark:text-red-300 text-sm font-semibold leading-normal";
    } else {
        compBadge.classList.add("bg-orange-500/10", "dark:bg-orange-400/20", "ring-orange-500/20");
        compText.className = "text-orange-700 dark:text-orange-300 text-sm font-semibold leading-normal";
    }

    // Answers
    document.getElementById('ans-what').innerHTML = formatText(data.answers.what);
    document.getElementById('ans-why').innerHTML = formatText(data.answers.why);
    document.getElementById('ans-who').innerHTML = formatText(data.answers.who);
    document.getElementById('ans-where').innerHTML = formatText(data.answers.where);
    document.getElementById('ans-when').innerHTML = formatText(data.answers.when);
    document.getElementById('ans-how').innerHTML = formatText(data.answers.how);
}

btnBackToTopic.addEventListener('click', () => {
    showScreen(screenTopic);
});

btnAdjustRole.addEventListener('click', () => {
    showScreen(screenProfession);
});

// INIT
validateProfession();
