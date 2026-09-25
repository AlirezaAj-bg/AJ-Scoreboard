const $ = (id) => document.getElementById(id);

const ICONS = {
    police: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>',
    medic: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 3h6v6h6v6h-6v6H9v-6H3V9h6z"/></svg>',
    wrench: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>',
    taxi: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 17h14v-5l-2-5H7l-2 5v5z"/><circle cx="7.5" cy="17.5" r="1.5"/><circle cx="16.5" cy="17.5" r="1.5"/><path d="M5 12h14M10 4h4"/></svg>',
    gavel: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m14 13-7.5 7.5a2.12 2.12 0 0 1-3-3L11 10M16 16l6-6M8 8l6-6M9 7l8 8M21 11l-8-8"/></svg>',
    star: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 2 3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>',
    users: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>',
    radar: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/></svg>',
    logout: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/></svg>',
    lock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>',
    unlock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 9.9-1"/></svg>',
    clock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>',
    mic: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 14a3 3 0 0 0 3-3V5a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11h-2z"/></svg>',
};

const state = {
    open: false,
    tab: 0,
    myId: 0,
    maxPlayers: 0,
    nearbyDistance: 50,
    serverName: 'SERVER',
    jobCounters: [],
    showDisconnected: true,
    players: [],
    disconnected: [],
    activities: {},
    police: 0,
    jobs: {},
    nearby: [],
};

let TABS = [];

// ---------------------------------------------------------------- helpers

const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

const hue = (n) => (Number(n) * 47) % 360;

const initials = (name) => {
    const parts = String(name || '?').trim().split(/\s+/).filter(Boolean);
    const s = parts.length > 1 ? parts[0][0] + parts[1][0] : (parts[0] || '?').slice(0, 2);
    return esc(s.toUpperCase());
};

const pingRow = (ms) => {
    const cls = ms < 70 ? 'good' : ms < 140 ? 'mid' : 'bad';
    const on = ms < 50 ? 4 : ms < 90 ? 3 : ms < 150 ? 2 : 1;
    const bars = [1, 2, 3, 4].map((i) => `<i class="${i <= on ? 'on' : ''}"></i>`).join('');
    return `<div class="ping ${cls}"><div class="bars">${bars}</div>${ms}ms</div>`;
};

const agoText = (sec) => {
    if (sec < 60) return 'just now';
    const m = Math.floor(sec / 60);
    if (m < 60) return `${m}m ago`;
    return `${Math.floor(m / 60)}h ago`;
};

const setNum = (el, value) => {
    const v = String(value);
    if (el.textContent === v) return;
    el.textContent = v;
    el.classList.remove('bump');
    void el.offsetWidth;
    el.classList.add('bump');
};

const hexToRgb = (hex) => {
    const m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex || '');
    return m ? `${parseInt(m[1], 16)}, ${parseInt(m[2], 16)}, ${parseInt(m[3], 16)}` : null;
};

const emptyBox = (icon, title, text) => `<div class="empty">${ICONS[icon]}<b>${title}</b>${text}</div>`;

const playerById = (id) => state.players.find((p) => p.id === id);

// ---------------------------------------------------------------- tabs

function buildTabs() {
    TABS = [
        { key: 'players', label: 'Players', count: () => state.players.length },
        { key: 'nearby', label: 'Nearby', count: () => state.nearby.length },
    ];
    if (state.showDisconnected) TABS.push({ key: 'left', label: 'Left', count: () => state.disconnected.length });
    TABS.push({ key: 'heists', label: 'Heists', count: () => Object.keys(state.activities).length });

    const track = $('tabs');
    track.querySelectorAll('.tab').forEach((t) => t.remove());
    TABS.forEach((t, i) => {
        const el = document.createElement('div');
        el.className = 'tab';
        el.dataset.i = i;
        el.innerHTML = `${t.label}<span class="n"></span>`;
        track.appendChild(el);
    });
    $('tile-left').parentElement.style.display = state.showDisconnected ? '' : 'none';
    document.querySelector('.tiles').style.gridTemplateColumns = `repeat(${state.showDisconnected ? 3 : 2}, 1fr)`;
    if (state.tab >= TABS.length) state.tab = 0;
    updateTabs();
}

function updateTabs() {
    const tabs = $('tabs').querySelectorAll('.tab');
    tabs.forEach((el, i) => {
        el.classList.toggle('active', i === state.tab);
        el.querySelector('.n').textContent = TABS[i].count();
    });
    const active = tabs[state.tab];
    if (active) {
        const ink = $('tab-ink');
        ink.style.width = `${active.offsetWidth}px`;
        ink.style.transform = `translateX(${active.offsetLeft - ink.offsetLeft}px)`;
    }
}

function switchTab(dir) {
    state.tab = (state.tab + dir + TABS.length) % TABS.length;
    updateTabs();
    render(true);
}

// ---------------------------------------------------------------- renderers

function renderPlayers() {
    if (!state.players.length) return emptyBox('users', 'No players', 'Nobody is online right now.');
    const near = new Map(state.nearby.map((n) => [n.id, n]));
    const sorted = [...state.players].sort((a, b) => (a.id === state.myId ? -1 : b.id === state.myId ? 1 : a.id - b.id));
    return sorted.map((p, i) => {
        const me = p.id === state.myId;
        const n = near.get(p.id);
        const tags = [
            me ? '<span class="tag you">You</span>' : '',
            p.staff ? '<span class="tag staff">Staff</span>' : '',
            n && n.talking ? `<span class="mic">${ICONS.mic}</span>` : '',
        ].join('');
        const sub = [
            `<span class="id">ID ${p.id}</span>`,
            p.job ? `<span>${esc(p.job)}</span>` : '',
            n ? `<span>${n.dist}m away</span>` : '',
        ].filter(Boolean).join('<span>·</span>');
        return `<div class="row ${me ? 'me' : ''} ${n && n.talking ? 'talking' : ''}" style="--i:${i}">
            <div class="av" style="--h:${hue(p.id)}">${initials(p.name)}</div>
            <div class="meta"><div class="name"><span>${esc(p.name)}</span>${tags}</div><div class="sub">${sub}</div></div>
            ${pingRow(p.ping)}
        </div>`;
    }).join('');
}

function renderNearby() {
    if (!state.nearby.length) return emptyBox('radar', 'Nobody nearby', `No players within ${state.nearbyDistance}m of you.`);
    return state.nearby.map((n, i) => {
        const p = playerById(n.id);
        const name = p ? p.name : `Player ${n.id}`;
        return `<div class="row ${n.talking ? 'talking' : ''}" style="--i:${i}">
            <div class="av" style="--h:${hue(n.id)}">${initials(name)}</div>
            <div class="meta">
                <div class="name"><span>${esc(name)}</span>${p && p.staff ? '<span class="tag staff">Staff</span>' : ''}${n.talking ? `<span class="mic">${ICONS.mic}</span>` : ''}</div>
                <div class="sub"><span class="id">ID ${n.id}</span>${n.talking ? '<span>·</span><span>Talking</span>' : ''}</div>
            </div>
            <span class="chip dist">${n.dist}m</span>
        </div>`;
    }).join('');
}

function renderLeft() {
    if (!state.disconnected.length) return emptyBox('logout', 'No recent disconnects', 'Players who leave will show up here for a while.');
    return state.disconnected.map((d, i) => `<div class="row" style="--i:${i}">
        <div class="av plain">${ICONS.logout}</div>
        <div class="meta">
            <div class="name"><span>${esc(d.name)}</span></div>
            <div class="sub"><span class="id">ID ${d.id}</span>${d.reason ? `<span>·</span><span class="reason">${esc(d.reason)}</span>` : ''}</div>
        </div>
        <span class="ago">${agoText(d.ago)}</span>
    </div>`).join('');
}

function renderHeists() {
    const list = Object.entries(state.activities);
    if (!list.length) return emptyBox('lock', 'No activities', 'No heists are configured.');
    const cops = state.police;
    return list
        .map(([key, a]) => ({ key, ...a }))
        .sort((a, b) => a.minimumPolice - b.minimumPolice)
        .map((a, i) => {
            let status, chip, icon;
            if (a.busy) { status = 'busy'; chip = 'In progress'; icon = 'clock'; }
            else if (cops >= a.minimumPolice) { status = 'ok'; chip = 'Available'; icon = 'unlock'; }
            else { status = 'locked'; chip = `Need ${a.minimumPolice - cops} more`; icon = 'lock'; }
            const pct = a.minimumPolice > 0 ? Math.min(100, (cops / a.minimumPolice) * 100) : 100;
            return `<div class="row" style="--i:${i}">
                <div class="av ${status}">${ICONS[icon]}</div>
                <div class="meta">
                    <div class="name"><span>${esc(a.label)}</span></div>
                    <div class="sub"><span>Police ${Math.min(cops, a.minimumPolice)}/${a.minimumPolice}</span></div>
                    <div class="progress ${status}"><i style="width:${pct}%"></i></div>
                </div>
                <span class="chip ${status}">${chip}</span>
            </div>`;
        }).join('');
}

const RENDERERS = { players: renderPlayers, nearby: renderNearby, left: renderLeft, heists: renderHeists };

function render(animate) {
    const list = $('list');
    const tab = TABS[state.tab];
    if (!tab) return;
    list.classList.toggle('anim', !!animate);
    list.innerHTML = RENDERERS[tab.key]();
    if (animate) list.scrollTop = 0;
}

function renderHeader() {
    const online = state.players.length;
    setNum($('count-online'), online);
    $('count-max').textContent = state.maxPlayers;
    $('cap-fill').style.width = `${state.maxPlayers ? Math.min(100, (online / state.maxPlayers) * 100) : 0}%`;
    setNum($('tile-online'), online);
    setNum($('tile-nearby'), state.nearby.length);
    setNum($('tile-left'), state.disconnected.length);

    $('services').innerHTML = state.jobCounters.map((c) => {
        const n = state.jobs[c.job] || 0;
        return `<div class="svc ${n > 0 ? 'active' : 'zero'}">${ICONS[c.icon] || ICONS.star}<b>${n}</b><span>${esc(c.label)}</span></div>`;
    }).join('');

    const me = playerById(state.myId);
    $('me-id').textContent = `ID ${state.myId}`;
    $('me-ping').textContent = me ? `${me.ping} ms` : '— ms';
    updateTabs();
}

// ---------------------------------------------------------------- actions

function setup(d) {
    state.serverName = d.serverName || 'SERVER';
    state.jobCounters = d.jobCounters || [];
    state.showDisconnected = d.showDisconnected !== false;
    $('server-name').textContent = state.serverName;
    $('brand-mark').textContent = d.tag || 'AJ';
    $('brand-mark').hidden = d.tag === '';
    $('hint-key').textContent = d.openKey || 'HOME';
    $('hint-verb').textContent = d.toggle === false ? 'Release' : 'Close';
    const rgb = hexToRgb(d.accent);
    if (rgb) {
        $('sb').style.setProperty('--accent', d.accent);
        $('sb').style.setProperty('--accent-rgb', rgb);
    }
    buildTabs();
}

function open(d) {
    state.open = true;
    state.myId = d.myId;
    state.maxPlayers = d.maxPlayers;
    state.nearbyDistance = d.nearbyDistance || state.nearbyDistance;
    $('sb').classList.add('on');
    renderHeader();
    render(true);
    requestAnimationFrame(updateTabs);
}

function close() {
    state.open = false;
    $('sb').classList.remove('on');
}

function update(d) {
    const firstLoad = state.players.length === 0;
    state.players = d.players || [];
    state.disconnected = d.disconnected || [];
    state.activities = d.activities || {};
    state.police = d.police || 0;
    state.jobs = d.jobs || {};
    renderHeader();
    const keep = $('list').scrollTop;
    render(firstLoad);
    if (!firstLoad) $('list').scrollTop = keep;
}

function nearby(list) {
    const before = JSON.stringify(state.nearby);
    state.nearby = list || [];
    if (before === JSON.stringify(state.nearby)) return;
    setNum($('tile-nearby'), state.nearby.length);
    updateTabs();
    const key = TABS[state.tab] && TABS[state.tab].key;
    if (key === 'nearby' || key === 'players') {
        const keep = $('list').scrollTop;
        render(false);
        $('list').scrollTop = keep;
    }
}

function scroll(dir) {
    $('list').scrollBy({ top: dir * 160, behavior: 'smooth' });
}

window.addEventListener('message', (e) => {
    const d = e.data || {};
    switch (d.action) {
        case 'setup': setup(d); break;
        case 'open': open(d); break;
        case 'close': close(); break;
        case 'update': update(d.data || {}); break;
        case 'nearby': nearby(d.list); break;
        case 'tab': if (state.open) switchTab(d.dir); break;
        case 'scroll': if (state.open) scroll(d.dir); break;
    }
});

window.addEventListener('resize', updateTabs);

buildTabs();
