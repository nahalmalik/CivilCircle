<?php
function appLayout($title, $content, $sidebarActive = 'dashboard') {
    echo '<!DOCTYPE html>';
?>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo e($title ?? 'CivilCircle'); ?> - CivilCircle</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0F044C;
            --secondary: #141E61;
            --accent: #787A91;
            --bg: #EEEEEE;
            --surface: rgba(255,255,255,0.92);
            --surface-strong: #ffffff;
            --border: rgba(15,4,76,0.10);
            --text: #111827;
            --muted: #6b7280;
            --success: #0f766e;
            --danger: #dc2626;
            --shadow: 0 20px 55px rgba(15,4,76,0.12);
            --radius: 22px;
        }
        * { box-sizing: border-box; }
        body { margin:0; font-family:'Inter', Arial, sans-serif; background: linear-gradient(135deg, var(--bg), #f8f8fd); color:var(--text); }
        a { color:inherit; text-decoration:none; }
        .app-shell { min-height:100vh; display:grid; grid-template-columns: 270px 1fr; }
        .sidebar { background: linear-gradient(180deg, var(--primary) 0%, var(--secondary) 100%); color:#fff; padding:24px 18px; display:flex; flex-direction:column; gap:18px; position:sticky; top:0; height:100vh; }
        .brand { display:flex; align-items:center; gap:12px; font-weight:700; font-size:1.05rem; }
        .brand-mark { width:44px; height:44px; border-radius:14px; display:grid; place-items:center; background: rgba(255,255,255,0.16); }
        .sidebar-nav { display:flex; flex-direction:column; gap:8px; margin-top:8px; }
        .nav-item { padding:12px 14px; border-radius:14px; display:flex; align-items:center; gap:10px; color:rgba(255,255,255,0.92); transition: all .2s ease; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,0.16); transform: translateX(2px); }
        .main-panel { display:flex; flex-direction:column; min-height:100vh; }
        .topbar { position:sticky; top:0; z-index:20; padding:18px 24px; background: rgba(255,255,255,0.74); backdrop-filter: blur(20px); border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; gap:16px; }
        .topbar-left, .topbar-right { display:flex; align-items:center; gap:12px; }
        .search-box { display:flex; align-items:center; gap:8px; padding:10px 14px; border:1px solid var(--border); border-radius:999px; background: var(--surface-strong); min-width:260px; }
        .search-box input { border:none; outline:none; background:transparent; font-size:0.94rem; width:100%; }
        .avatar { width:42px; height:42px; border-radius:50%; background: linear-gradient(135deg, var(--primary), var(--accent)); color:#fff; display:grid; place-items:center; font-weight:700; }
        .content { padding:24px; display:flex; flex-direction:column; gap:20px; }
        .page-shell { display:flex; flex-direction:column; gap:18px; }
        .page-header { display:flex; justify-content:space-between; align-items:flex-start; gap:12px; }
        .page-header h1 { margin:6px 0 6px; font-size:1.6rem; }
        .page-header p { margin:0; color:var(--muted); }
        .eyebrow { display:inline-flex; padding:6px 10px; border-radius:999px; background: rgba(20,30,97,0.1); color:var(--secondary); font-weight:700; font-size:0.82rem; }
        .panel-card { background: var(--surface); border:1px solid var(--border); border-radius:var(--radius); box-shadow:var(--shadow); padding:22px; }
        .grid { display:grid; gap:16px; }
        .grid.two { grid-template-columns:repeat(2, minmax(0, 1fr)); }
        .field { display:flex; flex-direction:column; gap:8px; }
        .field label { font-weight:600; color:var(--secondary); }
        .field input, .field textarea, .field select { border:1px solid rgba(15,4,76,0.14); border-radius:16px; padding:12px 14px; font:inherit; background:rgba(255,255,255,0.9); }
        .field textarea { min-height:110px; }
        .btn { border:none; border-radius:999px; padding:12px 16px; font-weight:700; cursor:pointer; background: linear-gradient(135deg, var(--primary), var(--secondary)); color:#fff; box-shadow:0 14px 24px rgba(20,30,97,0.18); }
        .btn-secondary { background: #fff; color:var(--secondary); border:1px solid var(--border); box-shadow:none; }
        .stacked-form { display:flex; flex-direction:column; gap:20px; }
        .section-title { font-size:1.05rem; font-weight:700; margin-bottom:14px; color:var(--primary); }
        .muted { color:var(--muted); }
        .message { border-radius:16px; padding:12px 14px; font-size:0.95rem; }
        .message.error { background: rgba(220,38,38,0.1); color:var(--danger); }
        .message.success { background: rgba(15,118,110,0.1); color:var(--success); }
        .message.info { background: rgba(20,30,97,0.08); color:var(--secondary); }
        .subject-group-card { background: rgba(255,255,255,0.8); border:1px solid rgba(15,4,76,0.1); border-radius:20px; padding:16px; display:flex; flex-direction:column; gap:12px; margin-bottom:12px; }
        .subject-group-header { display:flex; justify-content:space-between; align-items:flex-start; gap:12px; }
        .subject-group-header h3 { margin:0 0 4px; font-size:1rem; }
        .subject-group-header p { margin:0; color:var(--muted); font-size:0.92rem; }
        .marks-pill { padding:8px 10px; border-radius:999px; background: rgba(20,30,97,0.1); color:var(--secondary); font-size:0.8rem; font-weight:700; }
        .subject-options { display:grid; grid-template-columns:repeat(2, minmax(0, 1fr)); gap:10px; }
        .subject-option { display:flex; gap:10px; align-items:flex-start; padding:12px; border:1px solid rgba(15,4,76,0.10); border-radius:16px; background:white; }
        .subject-option strong { display:block; }
        .subject-option small { color:var(--muted); display:block; margin-top:4px; }
        .selection-summary { margin-top:12px; display:flex; justify-content:space-between; gap:12px; align-items:center; padding:12px 14px; border-radius:16px; background: rgba(20,30,97,0.06); }
        .selection-summary.invalid { background: rgba(220,38,38,0.08); }
        .actions-row { display:flex; justify-content:flex-end; }
        .footer { padding:18px 24px 30px; color:var(--muted); font-size:0.9rem; }
        @media (max-width: 980px) { .app-shell { grid-template-columns:1fr; } .sidebar { height:auto; position:relative; } .subject-options { grid-template-columns:1fr; } .grid.two { grid-template-columns:1fr; } }
        @media (max-width: 640px) { .topbar { flex-wrap:wrap; } .search-box { min-width:0; flex:1; } .content { padding:16px; } .page-header { flex-direction:column; } }
    </style>
</head>
<body>
    <div class="app-shell">
        <aside class="sidebar">
            <div class="brand">
                <div class="brand-mark">CC</div>
                <div>CivilCircle</div>
            </div>
            <div class="sidebar-nav">
                <a class="nav-item <?php echo $sidebarActive === 'dashboard' ? 'active' : ''; ?>" href="<?php echo e(url('dashboard')); ?>">📊 Dashboard</a>
                <a class="nav-item <?php echo $sidebarActive === 'subjects' ? 'active' : ''; ?>" href="<?php echo e(url('profile/settings')); ?>">🗂 Optional Subjects</a>
                <a class="nav-item" href="<?php echo e(url('profile/settings')); ?>">👤 Profile</a>
                <a class="nav-item" href="<?php echo e(url('logout')); ?>">↩ Logout</a>
            </div>
        </aside>
        <main class="main-panel">
            <header class="topbar">
                <div class="topbar-left">
                    <div class="search-box">🔎 <input placeholder="Search"></div>
                </div>
                <div class="topbar-right">
                    <div>☾</div>
                    <div>🔔</div>
                    <div class="avatar">U</div>
                </div>
            </header>
            <section class="content">
                <?php echo $content; ?>
            </section>
            <footer class="footer">CivilCircle • By Aspirants, For Aspirants</footer>
        </main>
    </div>
</body>
</html>
<?php
}
