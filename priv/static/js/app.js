import { Socket } from './phoenix.js';

let urlParams = {};
(window.onpopstate = function () {
  var match,
    pl     = /\+/g,  // Regex for replacing addition symbol with a space
    search = /([^&=]+)=?([^&]*)/g,
    decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
    query  = window.location.search.substring(1);

  urlParams = {};
  while (match = search.exec(query))
    urlParams[decode(match[1])] = decode(match[2]);
})();

const radios = {
  'fip': 'https://stream.radiofrance.fr/fip/fip_hifi.m3u8?id=livesongdemo',
  'electro': 'https://stream.radiofrance.fr/fipelectro/fipelectro_hifi.m3u8?id=livesongdmeo'
}

let socket = null;
let channel = null;
let connected = 0;
let hls = null;

const video = document.getElementById('audio');
if (urlParams['muted'] === '1') {
  video.setAttribute('muted', true);
  video.muted = true;
}

const videoSrc = radios[urlParams['radio']];
const songElem = document.getElementById('song');
const listenersElem = document.getElementById('listeners');

/* note that this auto-load the source even when not playing, for some reasons
    I couldn't get a reliable way to load only when play was clicked in both FF and Chrome. */
if (Hls.isSupported()) {
  hls = new Hls();
  hls.loadSource(videoSrc);
  hls.attachMedia(video);
} else if (video.canPlayType('application/vnd.apple.mpegurl')) {
  video.src = videoSrc;
}

const resetSocket = () => {
  if (socket !== null) {
    socket.disconnect();
    socket = null;
  }
  channel = null;
  songElem.innerText = '';
  listenersElem.innerText = '';
  connected = 0;
};

video.onpause = () => {
  console.log('Pause');
  resetSocket();
};


video.onplay = () => {
  console.log('Playing');

  if (Hls.isSupported()) {
    // hls.loadSource(videoSrc);
  }

  const url = new URL(window.location);
  const protocol = document.location.protocol === 'https:' ? 'wss' : 'ws';

  socket = new Socket(`${protocol}://${url.host}/socket`);
  socket.connect();
  socket.onError(() => {
    resetSocket();
  });

  channel = socket.channel(`radio:${urlParams['radio']}`, {})
  channel.join()
    .receive('ok', resp => {
      console.log('Joined successfully', resp)
    })
    .receive('error', resp => {
      console.log('Unable to join', resp)
      resetSocket();
    });

  channel.on('playing', payload => {
    let song = '';
    if (payload.artist !== null) {
      song += payload.artist;
    }

    if (payload.title !== null) {
      if (payload.artist !== null) {
        song += ' - ';
      }

      song += payload.title;
    }

    songElem.innerText = song;
  });

  channel.on('presence_state', payload => {
    if (payload !== null) {
      connected = Object.keys(payload).length;
      listenersElem.innerText = `${connected} listener${connected > 1 ? 's' : ''}.`
    } else {
      listenersElem.innerText = '';
    }
  });

  channel.on('presence_diff', payload => {
    const joins = Object.keys(payload.joins).length;
    const leaves = Object.keys(payload.leaves).length;
    connected = connected + joins - leaves;
    listenersElem.innerText = `${connected} listener${connected > 1 ? 's' : ''}.`;
  });
};
