<?php
$groups = $subjectGroups ?? [];
$selectedSubjectIds = $selectedSubjectIds ?? [];
$selectedSubjects = $selectedSubjects ?? [];
?>
<div class="page-shell">
    <div class="page-header">
        <div>
            <div class="eyebrow">Profile settings</div>
            <h1>Complete your profile</h1>
            <p>Share the essentials and choose your optional subjects from the FPSC-approved groups.</p>
        </div>
        <a class="btn btn-secondary" href="<?php echo e(url('dashboard')); ?>">Back to dashboard</a>
    </div>

    <?php if (!empty($errors)): ?><div class="message error"><?php echo e(implode('<br>', $errors)); ?></div><?php endif; ?>
    <?php if (!empty($success)): ?><div class="message success"><?php echo e($success); ?></div><?php endif; ?>

    <form method="post" action="<?php echo e(url('profile/settings')); ?>" enctype="multipart/form-data" class="stacked-form">
        <input type="hidden" name="_csrf_token" value="<?php echo e($csrfToken ?? ''); ?>">

        <section class="panel-card">
            <div class="section-title">Personal information</div>
            <div class="grid two">
                <div class="field">
                    <label for="full_name">Full name</label>
                    <input id="full_name" name="full_name" value="<?php echo e($profile['full_name'] ?? ''); ?>">
                </div>
                <div class="field">
                    <label for="city">City</label>
                    <input id="city" name="city" value="<?php echo e($profile['city'] ?? ''); ?>">
                </div>
                <div class="field">
                    <label for="profession">Profession / Last degree</label>
                    <input id="profession" name="profession" value="<?php echo e($profile['profession'] ?? ''); ?>">
                </div>
                <div class="field">
                    <label for="css_attempt">CSS attempt</label>
                    <input id="css_attempt" name="css_attempt" type="number" min="1" max="10" value="<?php echo e($profile['css_attempt'] ?? 0); ?>">
                </div>
                <div class="field">
                    <label for="daily_study_goal">Daily study goal (hours)</label>
                    <input id="daily_study_goal" name="daily_study_goal" type="number" min="1" max="12" value="<?php echo e($profile['daily_study_goal'] ?? 0); ?>">
                </div>
                <div class="field">
                    <label for="avatar">Profile picture</label>
                    <input id="avatar" name="avatar" type="file">
                </div>
            </div>
            <div class="field">
                <label for="bio">Bio</label>
                <textarea id="bio" name="bio" rows="4"><?php echo e($profile['bio'] ?? ''); ?></textarea>
            </div>
        </section>

        <section class="panel-card">
            <div class="section-title">Academic information</div>
            <p class="muted">Choose optional subjects only from the FPSC CSS optional subject groups. Rules are enforced automatically.</p>
            <?php foreach ($groups as $group): ?>
                <div class="subject-group-card">
                    <div class="subject-group-header">
                        <div>
                            <h3><?php echo e($group['name']); ?></h3>
                            <p><?php echo e($group['description']); ?></p>
                        </div>
                        <div class="marks-pill"><?php echo e($group['marks_label']); ?></div>
                    </div>
                    <div class="subject-options">
                        <?php foreach ($group['subjects'] as $subject): ?>
                            <label class="subject-option">
                                <input type="checkbox"
                                    name="subjects[]"
                                    value="<?php echo e($subject['id']); ?>"
                                    data-group-id="<?php echo e($group['id']); ?>"
                                    data-max-selections="<?php echo e($group['max_selections']); ?>"
                                    data-rule="<?php echo e($group['rule']); ?>"
                                    <?php echo in_array((int) $subject['id'], $selectedSubjectIds, true) ? 'checked' : ''; ?>>
                                <span>
                                    <strong><?php echo e($subject['name']); ?></strong>
                                    <small><?php echo e($subject['marks']); ?> marks</small>
                                </span>
                            </label>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php endforeach; ?>
            <div class="selection-summary" id="selectionSummary">
                <div><strong>Current selected marks:</strong> <span id="selectedMarks">0</span></div>
                <div><strong>Maximum marks:</strong> 200</div>
                <div id="selectionMessage" class="message info">Select subjects according to the FPSC rules.</div>
            </div>
        </section>

        <div class="actions-row">
            <button class="btn" type="submit">Save profile</button>
        </div>
    </form>
</div>

<script>
(function () {
    const checkboxes = Array.from(document.querySelectorAll('input[name="subjects[]"]'));
    const summary = document.getElementById('selectionSummary');
    const selectedMarksEl = document.getElementById('selectedMarks');
    const messageEl = document.getElementById('selectionMessage');
    const markLookup = {
        '100': 100,
        '200': 200
    };

    function updateSelection() {
        const selected = checkboxes.filter(function (box) { return box.checked; });
        let selectedMarks = 0;
        selected.forEach(function (box) {
            const marks = box.getAttribute('data-marks') || '100';
            selectedMarks += parseInt(marks, 10);
        });
        selectedMarksEl.textContent = selectedMarks;

        let message = 'Select subjects according to the FPSC rules.';
        const groupCounts = {};
        selected.forEach(function (box) {
            const groupId = box.getAttribute('data-group-id');
            groupCounts[groupId] = (groupCounts[groupId] || 0) + 1;
        });

        const invalid = selected.some(function (box) {
            const rule = box.getAttribute('data-rule');
            const max = parseInt(box.getAttribute('data-max-selections') || '1', 10);
            const groupId = box.getAttribute('data-group-id');
            if (rule === 'one') {
                return groupCounts[groupId] > 1;
            }
            if (rule === 'group2-physics-chemistry') {
                const groupTwoSelection = selected.filter(function (item) {
                    return item.getAttribute('data-group-id') === '2';
                });
                return groupTwoSelection.length > 1;
            }
            return false;
        });

        if (invalid) {
            message = 'This combination is invalid for the FPSC subject rules.';
            if (summary) {
                summary.classList.add('invalid');
            }
        } else if (selectedMarks > 200) {
            message = 'Selected marks exceed the maximum allowed marks.';
            if (summary) {
                summary.classList.add('invalid');
            }
        } else {
            if (summary) {
                summary.classList.remove('invalid');
            }
            message = 'Selection looks valid.';
        }

        if (messageEl) {
            messageEl.textContent = message;
        }
    }

    checkboxes.forEach(function (box) {
        box.addEventListener('change', function () {
            const groupId = box.getAttribute('data-group-id');
            const maxSelections = parseInt(box.getAttribute('data-max-selections') || '1', 10);
            const rule = box.getAttribute('data-rule');
            const groupBoxes = checkboxes.filter(function (item) {
                return item.getAttribute('data-group-id') === groupId;
            });

            if (box.checked) {
                if (rule === 'one' && groupBoxes.filter(function (item) { return item.checked; }).length > 1) {
                    box.checked = false;
                }
                if (rule === 'group2-physics-chemistry' && groupId === '2' && box.checked) {
                    const physicsOrChemistry = groupBoxes.filter(function (item) {
                        return item.value === '16' || item.value === '17';
                    });
                    if (physicsOrChemistry.some(function (item) { return item.checked; }) && box.value !== '16' && box.value !== '17') {
                        box.checked = false;
                    }
                }
                if (rule === 'group2-100-marks' && groupBoxes.filter(function (item) { return item.checked; }).length > maxSelections) {
                    box.checked = false;
                }
            }
            updateSelection();
        });
    });

    updateSelection();
})();
</script>
