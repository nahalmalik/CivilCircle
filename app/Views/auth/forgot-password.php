<?php
ob_start();
if (!empty($errors)): ?><div class="message error"><?php echo e(implode('<br>', $errors)); ?></div><?php endif; ?>
<?php if (!empty($success)): ?><div class="message success"><?php echo e($success); ?></div><?php endif; ?>
<form method="post" action="<?php echo e(url('forgot-password')); ?>">
    <input type="hidden" name="_csrf_token" value="<?php echo e($csrfToken ?? ''); ?>">
    <div class="field">
        <label for="email">Email address</label>
        <div class="input-wrap">
            <input id="email" name="email" type="email" required>
            <span class="input-icon">✉</span>
        </div>
    </div>
    <button class="btn" type="submit">Send reset link</button>
    <div class="link-row">
        <span>Remembered it?</span>
        <a href="<?php echo e(url('login')); ?>">Back to sign in</a>
    </div>
</form>
<?php $content = ob_get_clean();
require dirname(__DIR__) . '/auth/layout.php';
authPageShell('Forgot password', 'Enter your email and we will send you a secure reset link.', $content, url('login'), 'Back to sign in');
