import { Socket } from './phoenix.js';

const maxLogsLines = 50;
let logs = [];
// const logsElem = document.getElementById('logs');
const logsWrapperElem = document.getElementsByClassName('logs-wrapper')[0];

console.log(logsWrapperElem);

const renderLogs = () => {
  logsWrapperElem.innerText = '';
  logs.forEach(function (value) {
    const newElem = document.createElement('div');
    newElem.innerHTML = value;
    logsWrapperElem.appendChild(newElem);
  });
}

let socket = null;
let channel = null;

const url = new URL(window.location);
const protocol = document.location.protocol === 'https:' ? 'wss' : 'ws';

socket = new Socket(`${protocol}://${url.host}/socket`);
socket.connect();
// socket.onError(() => { });

channel = socket.channel('logs:all', {})
channel.join()
  .receive('ok', resp => {
    console.log('Joined successfully', resp)
  })
  .receive('error', resp => {
    console.log('Unable to join', resp)
  });

channel.on('log', payload => {
  logs.push(`${payload.message.replace(/(\r\n|\n|\r)/gm, '')}\n`);
  if (logs.length > maxLogsLines) {
    logs.shift();
  }
  renderLogs();
});


