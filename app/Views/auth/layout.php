<?php
function authPageShell($title, $subtitle, $content, $footerLink = null, $footerLabel = null, $accent = null) {
    $accent = $accent ?: '#0F044C';
    echo '<!DOCTYPE html>'; ?>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo e($title ?? 'Authentication'); ?> - CivilCircle</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0F044C;
            --secondary: #141E61;
            --accent: #787A91;
            --bg: #EEEEEE;
            --surface: rgba(255,255,255,0.78);
            --border: rgba(255,255,255,0.55);
            --text: #111827;
            --muted: #6b7280;
            --success: #0f766e;
            --danger: #dc2626;
            --shadow: 0 30px 70px rgba(15, 4, 76, 0.18);
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            font-family: 'Inter', Arial, sans-serif;
            color: var(--text);
            background: radial-gradient(circle at top left, rgba(120,122,145,0.18), transparent 24%), linear-gradient(135deg, var(--bg), #f7f7fb);
            overflow-x: hidden;
        }
        body::before, body::after { content:''; position:fixed; inset:auto; width:320px; height:320px; border-radius:50%; filter:blur(60px); opacity:0.35; pointer-events:none; }
        body::before { top:-100px; left:-80px; background:#141E61; }
        body::after { right:-80px; bottom:-100px; background:#787A91; }
        .page { min-height:100vh; display:grid; grid-template-columns: 1.04fr 0.96fr; position:relative; }
        .hero { position:relative; padding: 44px 42px; display:flex; flex-direction:column; justify-content:center; background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 55%, var(--accent) 100%); color:#fff; overflow:hidden; }
        .hero::before { content:''; position:absolute; inset:0; background: radial-gradient(circle at 20% 20%, rgba(255,255,255,0.18), transparent 28%), radial-gradient(circle at 80% 30%, rgba(255,255,255,0.12), transparent 25%), linear-gradient(120deg, transparent 0%, rgba(255,255,255,0.12) 100%); pointer-events:none; }
        .hero-shell { position:relative; z-index:1; max-width:600px; }
        .brand { display:flex; align-items:center; gap:12px; font-weight:700; font-size:1.05rem; letter-spacing:0.02em; margin-bottom:28px; }
        .brand-mark { width:44px; height:44px; border-radius:14px; background: rgba(255,255,255,0.18); display:grid; place-items:center; box-shadow: inset 0 1px 0 rgba(255,255,255,0.25); backdrop-filter: blur(14px); }
        .brand-mark span { font-weight:800; font-size:1.15rem; }
        .eyebrow { display:inline-flex; align-items:center; gap:8px; padding:8px 12px; border:1px solid rgba(255,255,255,0.2); border-radius:999px; background: rgba(255,255,255,0.12); font-size:0.9rem; margin-bottom:20px; backdrop-filter: blur(16px); }
        .hero h1 { font-size:2.4rem; line-height:1.08; margin:0 0 16px; font-weight:800; }
        .hero p { font-size:1rem; line-height:1.75; color:rgba(255,255,255,0.9); margin:0 0 28px; max-width:530px; }
        .hero-card { margin-top:28px; padding:24px; border-radius:24px; background: rgba(255,255,255,0.13); border:1px solid rgba(255,255,255,0.2); backdrop-filter: blur(18px); box-shadow: inset 0 1px 0 rgba(255,255,255,0.21); animation: float 6s ease-in-out infinite; }
        .hero-card .row { display:grid; grid-template-columns: repeat(3, 1fr); gap:10px; margin-top:10px; }
        .hero-card .pill { height:12px; border-radius:999px; background: rgba(255,255,255,0.22); }
        .hero-card .pill:nth-child(2) { width:70%; }
        .hero-card .pill:nth-child(3) { width:55%; }
        .panel { padding: 40px 32px; display:flex; align-items:center; justify-content:center; position:relative; }
        .auth-card { width:100%; max-width:500px; border-radius:28px; padding:32px; background: var(--surface); border:1px solid var(--border); backdrop-filter: blur(24px); box-shadow: var(--shadow); animation: rise .7s ease both; }
        .card-head { margin-bottom:20px; }
        .card-head h2 { margin:0 0 8px; font-size:1.6rem; font-weight:700; color:var(--primary); }
        .card-head p { margin:0; color:var(--muted); font-size:0.95rem; line-height:1.6; }
        .field { margin-bottom:14px; }
        .field label { display:block; margin-bottom:8px; font-size:0.9rem; font-weight:600; color:var(--secondary); }
        .input-wrap { position:relative; }
        .input-wrap input, .input-wrap select, .input-wrap textarea { width:100%; border:1px solid rgba(15,4,76,0.14); border-radius:16px; background: rgba(255,255,255,0.82); color:var(--text); padding:14px 46px 14px 16px; font-size:0.97rem; transition: all .2s ease; box-shadow: inset 0 1px 0 rgba(255,255,255,0.4); }
        .input-wrap textarea { min-height:92px; }
        .input-wrap input:focus, .input-wrap select:focus, .input-wrap textarea:focus { outline:none; border-color: rgba(20,30,97,0.42); box-shadow: 0 0 0 4px rgba(20,30,97,0.12); transform: translateY(-1px); }
        .input-icon { position:absolute; right:14px; top:50%; transform:translateY(-50%); color: var(--accent); }
        .password-toggle { position:absolute; right:16px; top:50%; transform:translateY(-50%); border:none; background:transparent; color:var(--accent); font-weight:600; cursor:pointer; }
        .checkbox-row { display:flex; align-items:center; justify-content:space-between; gap:10px; margin:10px 0 18px; font-size:0.92rem; color:var(--muted); }
        .checkbox-row label { display:flex; align-items:center; gap:8px; }
        .checkbox-row input { accent-color: var(--primary); width:16px; height:16px; }
        .btn { width:100%; border:none; border-radius:999px; padding:13px 16px; font-size:0.98rem; font-weight:700; color:#fff; cursor:pointer; background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%); box-shadow: 0 16px 30px rgba(20,30,97,0.2); transition: transform .2s ease, box-shadow .2s ease; }
        .btn:hover { transform: translateY(-1px); box-shadow: 0 20px 36px rgba(20,30,97,0.22); }
        .btn:disabled { opacity:.7; cursor:wait; }
        .link-row { margin-top:14px; display:flex; justify-content:space-between; align-items:center; font-size:0.92rem; color:var(--muted); }
        .link-row a { color:var(--secondary); text-decoration:none; font-weight:600; }
        .link-row a:hover { color:var(--primary); }
        .message { border-radius:16px; padding:12px 14px; margin-bottom:12px; font-size:0.95rem; line-height:1.5; }
        .message.error { background: rgba(220,38,38,0.09); color: var(--danger); border:1px solid rgba(220,38,38,0.2); }
        .message.success { background: rgba(15,118,110,0.1); color: var(--success); border:1px solid rgba(15,118,110,0.2); }
        .footer-note { margin-top:14px; text-align:center; color:var(--muted); font-size:0.9rem; }
        .divider { display:flex; align-items:center; gap:10px; margin:20px 0; color:var(--muted); font-size:0.86rem; }
        .divider::before, .divider::after { content:''; flex:1; height:1px; background: rgba(15,4,76,0.12); }
        .chip { display:inline-flex; align-items:center; gap:8px; padding:7px 10px; border-radius:999px; background: rgba(255,255,255,0.14); font-size:0.83rem; }
        @keyframes rise { from { opacity:0; transform: translateY(14px); } to { opacity:1; transform: translateY(0); } }
        @keyframes float { 0%,100% { transform:translateY(0px);} 50% { transform:translateY(-8px);} }
        @media (max-width: 980px) { .page { grid-template-columns: 1fr; } .hero { min-height:320px; padding:34px 24px; } .panel { padding: 24px 16px 32px; } }
        @media (max-width: 640px) { .auth-card { padding:24px; border-radius:24px; } .hero h1 { font-size:1.9rem; } .chip { font-size:0.78rem; } }
    </style>
</head>
<body>
    <div class="page">
        <section class="hero">
            <div class="hero-shell">
                <div class="brand">
                    <div class="brand-mark"><span>CC</span></div>
                    <div>CivilCircle</div>
                </div>
                <div class="eyebrow">By Aspirants, For Aspirants</div>
                <h1>Welcome to CivilCircle</h1>
                <p>A free community platform where CSS aspirants collaborate, share quality resources, discuss preparation strategies, and grow together.</p>
                <div class="hero-card">
                    <div class="chip">📚 Learning together</div>
                    <div class="row">
                        <div class="pill"></div>
                        <div class="pill"></div>
                        <div class="pill"></div>
                    </div>
                    <div style="margin-top:12px; display:flex; gap:8px; flex-wrap:wrap;">
                        <span class="chip">Community</span>
                        <span class="chip">Resources</span>
                        <span class="chip">Strategy</span>
                    </div>
                </div>
            </div>
        </section>
        <section class="panel">
            <div class="auth-card">
                <div class="card-head">
                    <h2><?php echo e($title ?? 'Authentication'); ?></h2>
                    <p><?php echo e($subtitle ?? 'Continue your journey with CivilCircle.'); ?></p>
                </div>
                <?php echo $content; ?>
                <?php if ($footerLink): ?>
                    <div class="footer-note"><a href="<?php echo e($footerLink); ?>" style="color:var(--secondary); font-weight:600; text-decoration:none;"><?php echo e($footerLabel); ?></a></div>
                <?php endif; ?>
            </div>
        </section>
    </div>
</body>
</html>
<?php
}
