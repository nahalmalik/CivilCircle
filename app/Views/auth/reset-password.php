<?php
ob_start();
if (!empty($errors)): ?><div class="message error"><?php echo e(implode('<br>', $errors)); ?></div><?php endif; ?>
<?php if (!empty($success)): ?><div class="message success"><?php echo e($success); ?></div><?php endif; ?>
<form method="post" action="<?php echo e(url('reset-password?token=' . $token)); ?>">
    <input type="hidden" name="_csrf_token" value="<?php echo e($csrfToken ?? ''); ?>">
    <input type="hidden" name="token" value="<?php echo e($token); ?>">
    <div class="field">
        <label for="password">New password</label>
        <div class="input-wrap">
            <input id="password" name="password" type="password" required>
            <button class="password-toggle" type="button" onclick="togglePassword('password', this)">Show</button>
        </div>
    </div>
    <div class="field">
        <label for="password_confirmation">Confirm password</label>
        <div class="input-wrap">
            <input id="password_confirmation" name="password_confirmation" type="password" required>
            <button class="password-toggle" type="button" onclick="togglePassword('password_confirmation', this)">Show</button>
        </div>
    </div>
    <button class="btn" type="submit">Reset password</button>
    <div class="link-row">
        <span>Ready?</span>
        <a href="<?php echo e(url('login')); ?>">Back to sign in</a>
    </div>
</form>
<?php $content = ob_get_clean();
require dirname(__DIR__) . '/auth/layout.php';
authPageShell('Reset password', 'Choose a strong password for your account.', $content, url('login'), 'Back to sign in');
