<?php
ob_start();
if (!empty($errors)): ?><div class="message error"><?php echo e(implode('<br>', $errors)); ?></div><?php endif; ?>
<?php if (!empty($success)): ?><div class="message success"><?php echo e($success); ?></div><?php endif; ?>
<form method="post" action="<?php echo e(url('login')); ?>" novalidate>
    <input type="hidden" name="_csrf_token" value="<?php echo e($csrfToken ?? ''); ?>">
    <div class="field">
        <label for="email">Email</label>
        <div class="input-wrap">
            <input id="email" name="email" type="email" required value="<?php echo e($old['email'] ?? ''); ?>">
            <span class="input-icon">✉</span>
        </div>
    </div>
    <div class="field">
        <label for="password">Password</label>
        <div class="input-wrap">
            <input id="password" name="password" type="password" required>
            <button class="password-toggle" type="button" onclick="togglePassword('password', this)">Show</button>
        </div>
    </div>
    <div class="checkbox-row">
        <label><input type="checkbox" name="remember" value="1"> Remember me</label>
        <a href="<?php echo e(url('forgot-password')); ?>">Forgot password?</a>
    </div>
    <button class="btn" type="submit">Sign in</button>
    <div class="link-row">
        <span>New here?</span>
        <a href="<?php echo e(url('register')); ?>">Create account</a>
    </div>
</form>
<?php $content = ob_get_clean();
require dirname(__DIR__) . '/auth/layout.php';
authPageShell('Sign in', 'Access your dashboard and continue your preparation journey.', $content, url('register'), 'Create an account');
