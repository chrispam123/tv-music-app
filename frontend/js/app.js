// API Gateway endpoint
const API_ENDPOINT = 'https://nwca9tor82.execute-api.eu-west-1.amazonaws.com/';

// DOM elements
const clockElement = document.getElementById('clock');
const dateElement = document.getElementById('date');
const statusElement = document.getElementById('status');
const songNameElement = document.getElementById('song-name');
const audioElement = document.getElementById('audio');

// Update clock every second
function updateClock() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');

    clockElement.textContent = `${hours}:${minutes}:${seconds}`;
}

// Update date
function updateDate() {
    const now = new Date();
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    dateElement.textContent = now.toLocaleDateString('es-ES', options);
}

// Fetch random song from API
async function loadMusic() {
    try {
        statusElement.textContent = 'Cargando música...';
        statusElement.className = 'status';

        const response = await fetch(API_ENDPOINT);

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        if (data.error) {
            throw new Error(data.error);
        }

        if (!data.url) {
            throw new Error('No se recibió URL de música');
        }

        // Load and play music
        audioElement.src = data.url;
        songNameElement.textContent = data.filename || 'Música aleatoria';

        audioElement.play()
            .then(() => {
                statusElement.textContent = 'Reproduciendo';
                statusElement.className = 'status success';
            })
            .catch(error => {
                throw new Error(`Error al reproducir: ${error.message}`);
            });

        // Load next song when current one ends
        audioElement.onended = () => {
            setTimeout(loadMusic, 2000);
        };

    } catch (error) {
        console.error('Error loading music:', error);
        statusElement.textContent = `Error: ${error.message}`;
        statusElement.className = 'status error';
        songNameElement.textContent = '';

        // Retry after 10 seconds
        setTimeout(loadMusic, 10000);
    }
}

// Initialize
updateClock();
updateDate();
setInterval(updateClock, 1000);

// Start loading music when page loads
loadMusic();

// Handle audio errors
audioElement.onerror = () => {
    statusElement.textContent = 'Error al cargar audio';
    statusElement.className = 'status error';
    setTimeout(loadMusic, 5000);
};
