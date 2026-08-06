<?php
ob_start();
if (!empty($errors)): ?><div class="message error"><?php echo e(implode('<br>', $errors)); ?></div><?php endif; ?>
<?php if (!empty($success)): ?><div class="message success"><?php echo e($success); ?></div><?php endif; ?>
<form method="post" action="<?php echo e(url('register')); ?>" novalidate>
    <input type="hidden" name="_csrf_token" value="<?php echo e($csrfToken ?? ''); ?>">
    <div class="field">
        <label for="username">Username</label>
        <div class="input-wrap">
            <input id="username" name="username" required value="<?php echo e($old['username'] ?? ''); ?>">
            <span class="input-icon">@</span>
        </div>
    </div>
    <div class="field">
        <label for="email">Email address</label>
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
    <div class="field">
        <label for="password_confirmation">Confirm password</label>
        <div class="input-wrap">
            <input id="password_confirmation" name="password_confirmation" type="password" required>
            <button class="password-toggle" type="button" onclick="togglePassword('password_confirmation', this)">Show</button>
        </div>
    </div>
    <div class="checkbox-row" style="align-items:flex-start; margin-top:16px;">
        <label><input id="terms" name="terms" type="checkbox" value="1"> I agree to the terms and community guidelines.</label>
    </div>
    <button class="btn" type="submit">Create account</button>
    <div class="link-row">
        <span>Already a member?</span>
        <a href="<?php echo e(url('login')); ?>">Sign in</a>
    </div>
</form>
<?php $content = ob_get_clean();
require dirname(__DIR__) . '/auth/layout.php';
authPageShell('Create account', 'Join the community and start building your CSS routine.', $content, url('login'), 'Already have an account? Sign in');
