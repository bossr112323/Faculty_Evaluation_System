<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ForgotPassword.aspx.vb" Inherits="Faculty_Evaluation_System.ForgotPassword" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Forgot Password - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #1a3a8f;
            --primary-light: #2a4aaf;
            --primary-dark: #0f2259;
            --gold: #d4af37;
            --gold-light: #e6c158;
            --gold-dark: #b8941f;
            --success: #28a745;
            --info: #17a2b8;
            --warning: #ffc107;
            --danger: #dc3545;
            --light: #f8f9fc;
            --dark: #343a40;
        }
        
        body {
            background: linear-gradient(135deg, #f8f9fc 0%, #e9ecef 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .password-container {
            width: 100%;
            max-width: 550px;
            margin: 0 auto;
        }
        
        .password-card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 0.5rem 2rem 0 rgba(58, 59, 69, 0.2);
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
            background: rgba(255, 255, 255, 0.95);
        }
        
        .password-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .password-header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 70%);
        }
        
        .password-header::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--gold) 0%, transparent 100%);
        }
        
        .password-body {
            padding: 2.5rem;
            background: white;
        }
        
        .form-control {
            border-radius: 0.5rem;
            padding: 0.75rem 1rem;
            border: 1px solid #d1d3e2;
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
            transform: translateY(-2px);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border: none;
            padding: 0.75rem 1.5rem;
            font-weight: 600;
            border-radius: 0.5rem;
            transition: all 0.3s;
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .btn-gold {
            background: linear-gradient(135deg, var(--gold) 0%, var(--gold-light) 100%);
            border: none;
            padding: 0.75rem 1.5rem;
            font-weight: 600;
            border-radius: 0.5rem;
            color: #333;
            transition: all 0.3s;
        }
        
        .btn-gold:hover {
            background: linear-gradient(135deg, var(--gold-dark) 0%, var(--gold) 100%);
            color: #333;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .password-icon {
            font-size: 3.5rem;
            margin-bottom: 1rem;
            color: white;
            position: relative;
            z-index: 1;
        }
        
        .info-box {
            background: linear-gradient(135deg, #f8f9fc 0%, #e9ecef 100%);
            border-left: 4px solid var(--gold);
            padding: 1.25rem;
            border-radius: 0.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .info-box i {
            color: var(--gold);
            margin-right: 0.5rem;
        }
        
        .back-link {
            color: var(--primary);
            text-decoration: none;
            transition: all 0.3s;
            font-weight: 500;
        }
        
        .back-link:hover {
            color: var(--primary-dark);
            transform: translateX(-3px);
        }
        
        .step-indicator {
            display: flex;
            justify-content: space-between;
            margin-bottom: 2.5rem;
            position: relative;
        }
        
        .step-indicator::before {
            content: '';
            position: absolute;
            top: 15px;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, var(--primary) 0%, #e3e6f0 100%);
            z-index: 1;
        }
        
        .step {
            text-align: center;
            z-index: 2;
            background: white;
            padding: 0 15px;
            flex: 1;
        }
        
        .step-circle {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background: linear-gradient(135deg, #e3e6f0 0%, #d1d3e2 100%);
            color: #6c757d;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 0.5rem;
            font-weight: bold;
            transition: all 0.3s;
            position: relative;
            z-index: 2;
        }
        
        .step.active .step-circle {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            transform: scale(1.1);
            box-shadow: 0 4px 10px rgba(26, 58, 143, 0.3);
        }
        
        .step.completed .step-circle {
            background: linear-gradient(135deg, var(--gold) 0%, var(--gold-light) 100%);
            color: #333;
        }
        
        .step-label {
            font-size: 0.85rem;
            color: #6c757d;
            display: block;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .step.active .step-label {
            color: var(--primary);
            font-weight: 600;
        }
        
        .resend-link {
            cursor: pointer;
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .resend-link:hover {
            color: var(--primary-dark);
            text-decoration: underline;
        }
        
        .resend-link.disabled {
            color: #6c757d;
            cursor: not-allowed;
            text-decoration: none;
        }

        /* Enhanced message styling */
        .alert-message {
            border-radius: 0.75rem;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            animation: slideIn 0.3s ease-out;
            display: flex;
            align-items: center;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .alert-success {
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
            color: #155724;
            border-left: 4px solid var(--success);
        }
        
        .alert-danger {
            background: linear-gradient(135deg, #f8d7da 0%, #f1b0b7 100%);
            color: #721c24;
            border-left: 4px solid var(--danger);
        }
        
        .alert-warning {
            background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
            color: #856404;
            border-left: 4px solid var(--warning);
        }
        
        .alert-info {
            background: linear-gradient(135deg, #d1ecf1 0%, #b6e3ea 100%);
            color: #0c5460;
            border-left: 4px solid var(--info);
        }
        
        .alert-icon {
            font-size: 1.5rem;
            margin-right: 0.75rem;
        }
        
        .input-group {
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .input-group-text {
            background: linear-gradient(135deg, #f8f9fc 0%, #e9ecef 100%);
            border-color: #d1d3e2;
            color: var(--primary);
            font-weight: 500;
        }
        
        .input-group:focus-within .input-group-text {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            border-color: var(--primary);
        }
        
        .form-label {
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.8rem;
            display: flex;
            align-items: center;
        }
        
        .form-label i {
            margin-right: 0.5rem;
            color: var(--gold);
        }
        
        .form-text {
            color: #6c757d;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        
        /* Password strength indicator */
        .password-strength {
            height: 4px;
            border-radius: 2px;
            margin-top: 0.5rem;
            background: #e9ecef;
            overflow: hidden;
        }
        
        .password-strength-bar {
            height: 100%;
            width: 0%;
            transition: all 0.3s;
            border-radius: 2px;
        }
        
        .strength-weak {
            background: var(--danger);
            width: 25%;
        }
        
        .strength-fair {
            background: var(--warning);
            width: 50%;
        }
        
        .strength-good {
            background: var(--info);
            width: 75%;
        }
        
        .strength-strong {
            background: var(--success);
            width: 100%;
        }
        
        /* Responsive styles */
        @media (max-width: 768px) {
            .password-body {
                padding: 2rem;
            }
            
            .password-container {
                max-width: 100%;
            }
            
            .step-label {
                font-size: 0.75rem;
            }
            
            .step-circle {
                width: 30px;
                height: 30px;
                font-size: 0.9rem;
            }
            
            .step-indicator::before {
                top: 15px;
            }
            
            .info-box {
                padding: 1rem;
            }
            
            .password-header {
                padding: 1.5rem;
            }
            
            .password-header h4 {
                font-size: 1.25rem;
            }
            
            .password-icon {
                font-size: 3rem;
            }
        }
        
        @media (max-width: 576px) {
            body {
                padding: 15px;
                align-items: flex-start;
                padding-top: 20px;
            }
            
            .password-body {
                padding: 1.5rem;
            }
            
            .step-label {
                font-size: 0.7rem;
            }
            
            .step {
                padding: 0 10px;
            }
            
            .step-circle {
                width: 28px;
                height: 28px;
                font-size: 0.8rem;
                margin-bottom: 0.25rem;
            }
            
            .step-indicator::before {
                top: 14px;
            }
            
            .input-group-text {
                padding: 0.5rem 0.75rem;
            }
            
            .btn-lg {
                padding: 0.75rem;
                font-size: 1rem;
            }
            
            .form-label {
                font-size: 0.9rem;
            }
            
            .form-text {
                font-size: 0.8rem;
            }
            
            .alert-message {
                padding: 0.875rem 1rem;
            }
        }
        
        @media (max-width: 400px) {
            .step-label {
                font-size: 0.65rem;
            }
            
            .step-circle {
                width: 25px;
                height: 25px;
                font-size: 0.75rem;
            }
            
            .step-indicator::before {
                top: 12.5px;
            }
        }
        
        /* Improved form styling for mobile */
        .form-control {
            font-size: 1rem;
        }
        
        @media (max-width: 576px) {
            .form-control {
                font-size: 16px; /* Prevents zoom on iOS */
                height: 44px; /* Better touch target */
            }
            
            .btn {
                min-height: 44px; /* Better touch target */
            }
        }
        
        /* Animation for panel transitions */
        .password-panel {
            transition: all 0.3s ease;
        }
        
        .fade-in {
            animation: fadeIn 0.5s ease;
        }
        
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="password-container">
            <div class="password-card">
                <div class="password-header">
                    <i class="bi bi-shield-lock password-icon"></i>
                    <h4 class="mb-0">Password Recovery</h4>
                    <p class="mb-0 mt-2 opacity-75">Golden West Colleges Faculty Evaluation System</p>
                </div>
                <div class="password-body">
                    <!-- Step Indicator -->
                    <div class="step-indicator">
                        <div class="step" id="step1">
                            <div class="step-circle">1</div>
                            <span class="step-label">Enter ID</span>
                        </div>
                        <div class="step" id="step2">
                            <div class="step-circle">2</div>
                            <span class="step-label">Verify Code</span>
                        </div>
                        <div class="step" id="step3">
                            <div class="step-circle">3</div>
                            <span class="step-label">New Password</span>
                        </div>
                    </div>
                    
                    <!-- Message Alert Container -->
                    <div id="messageAlert" class="alert-message d-none" runat="server">
                        <i id="alertIcon" class="alert-icon bi"></i>
                        <span id="messageText" runat="server"></span>
                        <button type="button" class="btn-close ms-auto" onclick="hideMessage()" aria-label="Close"></button>
                    </div>
                    
                    <!-- Step 1: School ID -->
                    <asp:Panel ID="pnlSchoolID" runat="server" CssClass="password-panel fade-in">
                        <div class="info-box">
                            <i class="bi bi-info-circle"></i>
                            Enter your School ID to receive a password reset code via email.
                        </div>
                        
                        <div class="mb-4">
                            <label for="txtSchoolID" class="form-label">
                                <i class="bi bi-person-badge"></i>School ID
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person-badge"></i></span>
                                <asp:TextBox ID="txtSchoolID" runat="server" CssClass="form-control" placeholder="Enter your School ID"></asp:TextBox>
                            </div>
                            <div class="form-text">Enter the School ID you use to log in to the system.</div>
                        </div>

                        <div class="d-grid mb-3">
                            <asp:Button ID="btnRequest" runat="server" Text="Send Reset Code" 
                                CssClass="btn btn-primary btn-lg" OnClick="btnRequest_Click" />
                        </div>
                    </asp:Panel>
                    
                    <!-- Step 2: Reset Code -->
                    <asp:Panel ID="pnlResetCode" runat="server" Visible="false" CssClass="password-panel fade-in">
                        <div class="info-box">
                            <i class="bi bi-envelope"></i>
                            We've sent a 6-digit reset code to your email address.
                        </div>
                        
                        <div class="mb-4">
                            <label for="txtResetCode" class="form-label">
                                <i class="bi bi-shield-check"></i>Reset Code
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-shield-check"></i></span>
                                <asp:TextBox ID="txtResetCode" runat="server" CssClass="form-control" 
                                    placeholder="Enter 6-digit code" MaxLength="6"></asp:TextBox>
                            </div>
                            <div class="form-text">
                                Didn't receive the code? 
                                <asp:LinkButton ID="btnResendCode" runat="server" CssClass="resend-link" OnClick="btnResendCode_Click" Text="Resend Code"></asp:LinkButton>
                                <span id="resendTimer" class="ms-2 text-muted d-none">Resend available in <span id="countdown">60</span>s</span>
                            </div>
                        </div>

                        <div class="d-grid mb-3">
                            <asp:Button ID="btnVerifyCode" runat="server" Text="Verify Code" 
                                CssClass="btn btn-primary btn-lg" OnClick="btnVerifyCode_Click" />
                        </div>
                    </asp:Panel>
                    
                    <!-- Step 3: New Password -->
                    <asp:Panel ID="pnlNewPassword" runat="server" Visible="false" CssClass="password-panel fade-in">
                        <div class="info-box">
                            <i class="bi bi-key"></i>
                            Please enter your new password.
                        </div>
                        
                        <div class="mb-3">
                            <label for="txtNewPassword" class="form-label">
                                <i class="bi bi-lock"></i>New Password
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" 
                                    placeholder="Enter new password" TextMode="Password"></asp:TextBox>
                            </div>
                            <div class="password-strength">
                                <div id="passwordStrengthBar" class="password-strength-bar"></div>
                            </div>
                            <div class="form-text">Password must be at least 8 characters long.</div>
                        </div>
                        
                        <div class="mb-4">
                            <label for="txtConfirmPassword" class="form-label">
                                <i class="bi bi-lock-fill"></i>Confirm Password
                            </label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" 
                                    placeholder="Confirm new password" TextMode="Password"></asp:TextBox>
                            </div>
                            <div id="passwordMatch" class="form-text"></div>
                        </div>

                        <div class="d-grid mb-3">
                            <asp:Button ID="btnResetPassword" runat="server" Text="Reset Password" 
                                CssClass="btn btn-primary btn-lg" OnClick="btnResetPassword_Click" />
                        </div>
                    </asp:Panel>
                    
                    <div class="text-center pt-3">
                        <a href="Login.aspx" class="back-link">
                            <i class="bi bi-arrow-left"></i> Back to Login
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Enhanced message display function
        function showMessage(message, type) {
            const messageAlert = document.getElementById('messageAlert');
            const messageText = document.getElementById('messageText');
            const alertIcon = document.getElementById('alertIcon');

            if (messageAlert && messageText && alertIcon) {
                // Set message content
                messageText.innerHTML = message;

                // Set alert styling and icon based on type
                messageAlert.className = 'alert-message alert-' + type;
                messageAlert.classList.remove('d-none');

                // Set appropriate icon
                switch (type) {
                    case 'success':
                        alertIcon.className = 'alert-icon bi bi-check-circle-fill';
                        break;
                    case 'danger':
                        alertIcon.className = 'alert-icon bi bi-exclamation-triangle-fill';
                        break;
                    case 'warning':
                        alertIcon.className = 'alert-icon bi bi-exclamation-circle-fill';
                        break;
                    case 'info':
                        alertIcon.className = 'alert-icon bi bi-info-circle-fill';
                        break;
                }

                // Auto dismiss after 5 seconds (except for success messages)
                if (type !== 'success') {
                    setTimeout(() => {
                        hideMessage();
                    }, 5000);
                }

                // Scroll to message for better visibility
                messageAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }
        }

        function hideMessage() {
            const messageAlert = document.getElementById('messageAlert');
            if (messageAlert) {
                messageAlert.classList.add('d-none');
            }
        }

        // Update step indicator based on visible panel
        function updateStepIndicator() {
            // Reset all steps
            document.querySelectorAll('.step').forEach(step => {
                step.classList.remove('active', 'completed');
            });

            // Check which panel is visible and update steps accordingly
            const pnlSchoolID = document.getElementById('<%= pnlSchoolID.ClientID %>');
            const pnlResetCode = document.getElementById('<%= pnlResetCode.ClientID %>');
            const pnlNewPassword = document.getElementById('<%= pnlNewPassword.ClientID %>');

            if (pnlSchoolID && pnlSchoolID.style.display !== 'none') {
                document.getElementById('step1').classList.add('active');
            } else if (pnlResetCode && pnlResetCode.style.display !== 'none') {
                document.getElementById('step1').classList.add('completed');
                document.getElementById('step2').classList.add('active');
            } else if (pnlNewPassword && pnlNewPassword.style.display !== 'none') {
                document.getElementById('step1').classList.add('completed');
                document.getElementById('step2').classList.add('completed');
                document.getElementById('step3').classList.add('active');
            }
        }

        // Password strength indicator
        function checkPasswordStrength(password) {
            const strengthBar = document.getElementById('passwordStrengthBar');
            if (!strengthBar) return;

            // Reset classes
            strengthBar.className = 'password-strength-bar';

            if (password.length === 0) {
                strengthBar.style.width = '0%';
                return;
            }

            let strength = 0;

            // Length check
            if (password.length >= 6) strength += 1;
            if (password.length >= 8) strength += 1;

            // Character variety checks
            if (/[a-z]/.test(password)) strength += 1;
            if (/[A-Z]/.test(password)) strength += 1;
            if (/[0-9]/.test(password)) strength += 1;
            if (/[^a-zA-Z0-9]/.test(password)) strength += 1;

            // Update strength bar
            if (strength <= 2) {
                strengthBar.classList.add('strength-weak');
            } else if (strength <= 4) {
                strengthBar.classList.add('strength-fair');
            } else if (strength <= 5) {
                strengthBar.classList.add('strength-good');
            } else {
                strengthBar.classList.add('strength-strong');
            }
        }

        // Password match checker
        function checkPasswordMatch() {
            const password = document.getElementById('<%= txtNewPassword.ClientID %>').value;
            const confirmPassword = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
            const matchIndicator = document.getElementById('passwordMatch');
            
            if (!matchIndicator) return;
            
            if (confirmPassword.length === 0) {
                matchIndicator.textContent = '';
                matchIndicator.className = 'form-text';
            } else if (password === confirmPassword) {
                matchIndicator.textContent = '✓ Passwords match';
                matchIndicator.className = 'form-text text-success';
            } else {
                matchIndicator.textContent = '✗ Passwords do not match';
                matchIndicator.className = 'form-text text-danger';
            }
        }

        // Prevent resend code spam
        let resendCooldown = 60;
        let cooldownInterval;

        function startResendCooldown() {
            const resendLink = document.getElementById('<%= btnResendCode.ClientID %>');
            const resendTimer = document.getElementById('resendTimer');
            const countdown = document.getElementById('countdown');
            
            if (resendLink && resendTimer && countdown) {
                resendLink.classList.add('disabled');
                resendLink.onclick = function(e) { e.preventDefault(); return false; };
                
                resendTimer.classList.remove('d-none');
                countdown.textContent = resendCooldown;
                
                clearInterval(cooldownInterval);
                
                cooldownInterval = setInterval(() => {
                    resendCooldown--;
                    countdown.textContent = resendCooldown;
                    
                    if (resendCooldown <= 0) {
                        clearInterval(cooldownInterval);
                        resendLink.classList.remove('disabled');
                        resendTimer.classList.add('d-none');
                        resendCooldown = 60;
                        // Reattach the server-side click handler
                        resendLink.onclick = null;
                    }
                }, 1000);
            }
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function () {
            updateStepIndicator();
            adjustLayoutForMobile();
            
            // Add event listeners for password fields
            const newPasswordField = document.getElementById('<%= txtNewPassword.ClientID %>');
            const confirmPasswordField = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            
            if (newPasswordField) {
                newPasswordField.addEventListener('input', function() {
                    checkPasswordStrength(this.value);
                    checkPasswordMatch();
                });
            }
            
            if (confirmPasswordField) {
                confirmPasswordField.addEventListener('input', checkPasswordMatch);
            }
            
            // Handle window resize
            window.addEventListener('resize', adjustLayoutForMobile);
            
            // Check if there's a server-side message to display
            const messageAlert = document.getElementById('messageAlert');
            if (messageAlert && !messageAlert.classList.contains('d-none')) {
                // Scroll to message if it's visible
                messageAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }
            
            // Start cooldown if we're on the reset code panel
            const pnlResetCode = document.getElementById('<%= pnlResetCode.ClientID %>');
            if (pnlResetCode && pnlResetCode.style.display !== 'none') {
                startResendCooldown();
            }
        });

        // Function to adjust layout for mobile devices
        function adjustLayoutForMobile() {
            const isMobile = window.innerWidth <= 576;
            const passwordBody = document.querySelector('.password-body');
            const stepLabels = document.querySelectorAll('.step-label');

            if (isMobile && passwordBody) {
                passwordBody.style.padding = '1.5rem';
                stepLabels.forEach(label => {
                    label.style.fontSize = '0.7rem';
                });
            } else if (passwordBody) {
                passwordBody.style.padding = '2.5rem';
                stepLabels.forEach(label => {
                    label.style.fontSize = '0.85rem';
                });
            }
        }
    </script>
</body>
</html>

