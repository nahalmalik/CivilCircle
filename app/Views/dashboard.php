<?php
ob_start();
?>
<div class="page-shell">
    <div class="page-header">
        <div>
            <div class="eyebrow">Dashboard</div>
            <h1>Good morning, <?php echo e($userName ?? 'Aspirant'); ?></h1>
            <p>Today is <?php echo e(date('l, F j, Y')); ?>. Keep your routine sharp and your focus steady.</p>
        </div>
        <a class="btn btn-secondary" href="<?php echo e(url('profile/settings')); ?>">Complete profile</a>
    </div>

    <div class="grid two">
        <div class="panel-card">
            <div class="section-title">Quick stats</div>
            <div class="grid two">
                <div class="panel-card" style="padding:14px;"><strong>Selected Subjects</strong><div>3</div></div>
                <div class="panel-card" style="padding:14px;"><strong>Resources Uploaded</strong><div>0</div></div>
                <div class="panel-card" style="padding:14px;"><strong>Questions Asked</strong><div>0</div></div>
                <div class="panel-card" style="padding:14px;"><strong>Vocabulary Progress</strong><div>42%</div></div>
            </div>
        </div>
        <div class="panel-card">
            <div class="section-title">Today’s focus</div>
            <p class="muted">Review the current affairs brief, complete one vocabulary set, and study one editorial.</p>
        </div>
    </div>
</div>
<?php $content = ob_get_clean();
require dirname(__DIR__) . '/Views/layouts/app.php';
appLayout($title ?? 'Dashboard', $content, 'dashboard');
