<?php
ob_start();
if (!empty($success)): ?><div class="message success"><?php echo e($message); ?></div><?php else: ?><div class="message error"><?php echo e($message); ?></div><?php endif; ?>
<div class="link-row">
    <span>Continue</span>
    <a href="<?php echo e(url('login')); ?>">Go to sign in</a>
</div>
<?php $content = ob_get_clean();
require dirname(__DIR__) . '/auth/layout.php';
authPageShell('Email verification', 'Verify your account and continue your preparation journey.', $content, url('login'), 'Go to sign in');
