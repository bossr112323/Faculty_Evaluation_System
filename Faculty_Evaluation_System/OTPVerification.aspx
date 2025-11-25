<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="OTPVerification.aspx.vb" Inherits="Faculty_Evaluation_System.OTPVerification" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <title>OTP Verification - Faculty Evaluation System</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700;800&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary: #1a3a8f;
            --primary-light: #2a4aaf;
            --primary-dark: #0f2259;
            --gold: #d4af37;
            --gold-light: #e6c158;
            --gold-dark: #b8941f;
            --secondary: #6c757d;
            --success: #28a745;
            --danger: #dc3545;
            --light-bg: #f8f9fc;
        }

        body {
            background:  
                linear-gradient(to bottom, rgba(0, 46, 110, 0.9), rgba(0, 85, 204, 0.8)),
                url('image/backgounds.jpg');
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 0.75rem;
        }

        .otp-container {
            width: 100%;
            max-width: 420px;
            margin: 0 auto;
        }

        .logo-container {
            display: flex;
            align-items: center;
            margin-bottom: 1.25rem;
            border-radius: 12px;
            padding: 0.75rem 0;
            gap: 0.75rem;
        }

        .logo-placeholder {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            overflow: hidden;
            justify-content: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            background: transparent;
            padding: 2px;
            flex-shrink: 0;
        }

        .institution-info {
            flex: 1;
        }

        .institution-name {
            font-family: 'Montserrat', sans-serif;
            font-weight: 800;
            font-size: 1.2rem;
            color: white;
            margin: 0;
            line-height: 1.2;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }

        .system-name {
            font-family: 'Poppins', sans-serif;
            font-weight: 600;
            font-size: 0.8rem;
            color: white;
            margin: 0.15rem 0 0 0;
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
        }

        .card {
            border: none;
            border-radius: 14px;
            box-shadow: 0 6px 25px rgba(0,0,0,0.1);
            overflow: hidden;
            backdrop-filter: blur(10px);
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid #e3e6f0;
        }

        .card-body {
            padding: 1.25rem;
        }

        .user-info {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            padding: 0.75rem;
            border-radius: 10px;
            margin-bottom: 1.25rem;
            text-align: center;
            border: 1px solid rgba(255,255,255,0.2);
            position: relative;
            overflow: hidden;
        }

        .user-info::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
            transform: rotate(45deg);
            animation: shine 3s infinite linear;
        }

        @keyframes shine {
            0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
            100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
        }

        .user-name {
            font-weight: 700;
            font-size: 1rem;
            margin-bottom: 0.2rem;
            position: relative;
            z-index: 1;
        }

        .user-role {
            font-size: 0.8rem;
            opacity: 0.9;
            position: relative;
            z-index: 1;
        }

        .user-email {
            font-size: 0.75rem;
            opacity: 0.8;
            margin-top: 0.4rem;
            position: relative;
            z-index: 1;
        }

        .form-label {
            font-weight: 600;
            margin-bottom: 0.4rem;
            color: var(--primary);
            font-size: 0.9rem;
        }

        .otp-input-group {
            position: relative;
            margin-bottom: 0.8rem;
        }

        .otp-input {
            text-align: center;
            font-size: 1.4rem;
            font-weight: 700;
            letter-spacing: 10px;
            padding: 0.65rem 0.8rem;
            border-radius: 8px;
            border: 1px solid #d1d3e2;
            transition: all 0.3s;
            background: white;
            font-family: 'Courier New', monospace;
            height: 50px;
        }

        .otp-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.3rem rgba(26, 58, 143, 0.25);
            outline: none;
            transform: translateY(-2px);
        }

        .otp-input::placeholder {
            letter-spacing: normal;
            color: #adb5bd;
            font-weight: 400;
        }

        .input-group-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--secondary);
            z-index: 5;
        }

        .input-with-icon {
            padding-left: 40px !important;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border: none;
            padding: 0.65rem;
            font-weight: 600;
            border-radius: 8px;
            transition: all 0.3s;
            font-size: 0.95rem;
            position: relative;
            overflow: hidden;
            height: 46px;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 100%);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d 0%, #868e96 100%);
            border: none;
            padding: 0.65rem;
            font-weight: 600;
            border-radius: 8px;
            transition: all 0.3s;
            font-size: 0.95rem;
            height: 46px;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            background: linear-gradient(135deg, #5a6268 0%, #727b84 100%);
        }

        .btn-secondary:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .alert {
            border-radius: 8px;
            padding: 0.6rem 0.8rem;
            border: none;
            border-left: 4px solid transparent;
            font-size: 0.85rem;
            margin-bottom: 0.8rem;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left-color: var(--success);
        }

        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border-left-color: var(--danger);
        }

        .alert-warning {
            background: #fff3cd;
            color: #856404;
            border-left-color: var(--gold);
        }

        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border-left-color: var(--primary);
        }

        .timer-container {
            background: linear-gradient(135deg, #f8f9fe 0%, #eef2ff 100%);
            padding: 0.6rem;
            border-radius: 8px;
            margin: 0.8rem 0;
            text-align: center;
            border: 1px solid #e1e5ee;
            position: relative;
        }

        .timer {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--primary);
            margin: 0;
        }

        .timer.expired {
            color: var(--danger);
            animation: pulse 1.5s infinite;
        }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.7; }
            100% { opacity: 1; }
        }

        .resend-info {
            font-size: 0.8rem;
            color: #6c757d;
            text-align: center;
            margin-top: 0.8rem;
            line-height: 1.4;
        }

        .back-to-login {
            text-align: center;
            margin-top: 1.25rem;
            padding-top: 0.8rem;
            border-top: 1px solid #e9ecef;
        }

        .back-link {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.9rem;
        }

        .back-link:hover {
            color: var(--primary-dark);
            text-decoration: underline;
            transform: translateX(-5px);
        }

        .logo-placeholder img {
            width: 100%;
            height: auto;
            object-fit: contain;
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.2));
        }

        .gold-accent {
            color: var(--gold);
        }

        .input-feedback {
            font-size: 0.8rem;
            margin-top: 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
            display: none;
        }

        .input-feedback.valid {
            color: var(--success);
        }

        .input-feedback.invalid {
            color: var(--danger);
        }

        .btn-spinner {
            display: inline-block;
            width: 0.9rem;
            height: 0.9rem;
            border: 2px solid transparent;
            border-top: 2px solid currentColor;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin-right: 0.4rem;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .footer {
            margin-top: 1rem;
        }

        .footer p {
            opacity: 0.9;
            font-size: 0.75rem;
            margin-bottom: 0;
        }

        /* Mobile-specific optimizations */
        @media (max-width: 576px) {
            body {
                padding: 0.5rem;
                align-items: flex-start;
                padding-top: 1.5rem;
            }
            
            .otp-container {
                max-width: 100%;
                margin: 0 auto;
            }
            
            .logo-container {
                flex-direction: column;
                text-align: center;
                padding: 0.75rem 0;
                gap: 0.6rem;
            }
            
            .logo-placeholder {
                width: 60px;
                height: 60px;
                margin-bottom: 0;
            }
            
            .institution-name {
                font-size: 1.1rem;
            }
            
            .system-name {
                font-size: 0.75rem;
            }
            
            .card-body {
                padding: 1rem;
            }
            
            .otp-input {
                font-size: 1.2rem;
                padding: 0.65rem 0.8rem;
                letter-spacing: 8px;
                height: 46px;
            }
            
            .user-info {
                padding: 0.65rem;
                margin-bottom: 1rem;
            }
            
            .user-name {
                font-size: 0.9rem;
            }
            
            .btn-primary, .btn-secondary {
                padding: 0.65rem;
                font-size: 0.9rem;
                height: 44px;
            }
            
            .timer-container {
                margin: 0.75rem 0;
                padding: 0.65rem;
            }
            
            .back-to-login {
                margin-top: 1rem;
            }
        }

        @media (max-width: 375px) {
            .logo-placeholder {
                width: 50px;
                height: 50px;
            }
            
            .institution-name {
                font-size: 1rem;
            }
            
            .card-body {
                padding: 0.85rem;
            }
            
            .otp-input {
                font-size: 1.1rem;
                padding: 0.6rem 0.7rem;
                letter-spacing: 6px;
                height: 44px;
            }
            
            .timer-container {
                padding: 0.6rem;
            }
        }

        /* Enhanced focus styles for accessibility */
        .btn-primary:focus,
        .otp-input:focus,
        .back-link:focus {
            outline: 2px solid var(--primary);
            outline-offset: 2px;
        }
    </style>
</head>
<body>
    <form id="frmOTP" runat="server">
        <div class="otp-container">
            <!-- Logo and Institution Name -->
            <div class="logo-container">
                <div class="logo-placeholder">
                    <img src="image/gwc.png" alt="Golden West Colleges Logo" class="logo-img" 
                         onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAiIGhlaWdodD0iODAiIHZpZXdCb3g9IjAgMCA4MCA4MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjgwIiBoZWlnaHQ9IjgwIiByeD0iNDAiIGZpbGw9IiMxYTNhOGYiLz4KPHN2ZyB4PSIyMCIgeT0iMjAiIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNENEFGMzciIHN0cm9rZS13aWR0aD0iMiI+CjxwYXRoIGQ9Ik0xMiAxMk0xMiAxNk0xMiAyME0xMiA4TTEyIDRNOSAyMk0xNSAyMk05IDJMMTUgMk0xOCAxNkwyMiAxNk0yIDE2TDYgMTZNMTggOEwyMiA4TTIgOEw2IDgiLz4KPC9zdmc+Cjwvc3ZnPg=='"/>
                </div>
                <div class="institution-info">
                    <h1 class="institution-name">GOLDEN WEST COLLEGES</h1>
                    <p class="system-name">Secure OTP Verification</p>
                </div>
            </div>

            <!-- OTP Card -->
            <div class="card">
                <div class="card-body">
                    <!-- User Info -->
                    <div class="user-info">
                        <div class="user-name" id="userName" runat="server"></div>
                        <div class="user-role" id="userRole" runat="server"></div>
                        <div class="user-email" id="userEmail" runat="server"></div>
                    </div>

                    <!-- Alert for messages -->
                    <asp:Label ID="lblMsg" runat="server" CssClass="alert d-block" />

                    <!-- OTP Input -->
                    <div class="mb-2">
                        <label for="txtOTP" class="form-label">
                            <i class="fas fa-shield-alt me-2 gold-accent"></i>Enter Verification Code
                        </label>
                        <div class="otp-input-group">
                            <div class="position-relative">
                                <i class="fas fa-key input-group-icon"></i>
                                <asp:TextBox ID="txtOTP" runat="server" CssClass="form-control otp-input input-with-icon" 
                                    MaxLength="6" placeholder="000000" AutoComplete="one-time-code" />
                            </div>
                            <div id="otpFeedback" class="input-feedback">
                                <i class="fas fa-check-circle"></i>
                                <span>Ready to verify</span>
                            </div>
                        </div>
                    </div>

                    <!-- Timer -->
                    <div class="timer-container">
                        <div class="timer" id="timerDisplay" runat="server">
                            <i class="fas fa-clock me-2"></i>
                            Code expires in: <span id="countdown" class="fw-bold">10:00</span>
                        </div>
                    </div>

                    <!-- Verify Button -->
                    <div class="d-grid gap-2 mb-2">
                        <button id="btnVerify" runat="server" onserverclick="btnVerify_Click" 
                            onclientclick="showLoading(this);" class="btn btn-primary" type="button">
                            <i class='fas fa-check-circle me-2'></i>Verify & Continue
                        </button>
                    </div>

                    <!-- Resend OTP -->
                    <div class="d-grid gap-2">
                        <button id="btnResend" runat="server" onserverclick="btnResend_Click" 
                            onclientclick="showLoading(this);" class="btn btn-secondary" type="button">
                            <i class='fas fa-redo-alt me-2'></i>Resend Code
                        </button>
                    </div>

                    <div class="resend-info">
                        <i class="fas fa-info-circle me-1"></i>
                        Check your email for the verification code. If you don't see it, please check your spam folder.
                    </div>

                    <!-- Back to Login -->
                    <div class="back-to-login">
                        <asp:LinkButton ID="lnkBack" runat="server" CssClass="back-link" OnClick="lnkBack_Click">
                            <i class="fas fa-arrow-left me-1"></i>Back to Login
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <!-- Security Footer -->
            <div class="footer text-center">
                <p class="text-white">
                    <i class="fas fa-lock me-1"></i>
                    Secure verification required for account access
                </p>
            </div>
        </div>

        <!-- Hidden field for remaining time -->
        <asp:HiddenField ID="hfRemainingTime" runat="server" Value="600" />
    </form>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Enhanced OTP Verification Script -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const remainingTime = parseInt(document.getElementById('<%= hfRemainingTime.ClientID %>').value) || 600;
            let timeLeft = remainingTime;
            const countdownElement = document.getElementById('countdown');
            const timerDisplay = document.getElementById('timerDisplay');
            const resendButton = document.getElementById('<%= btnResend.ClientID %>');
            const otpInput = document.getElementById('<%= txtOTP.ClientID %>');
            const otpFeedback = document.getElementById('otpFeedback');
            const verifyButton = document.getElementById('<%= btnVerify.ClientID %>');

            function updateTimer() {
                const minutes = Math.floor(timeLeft / 60);
                const seconds = timeLeft % 60;
                countdownElement.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

                if (timeLeft <= 0) {
                    countdownElement.textContent = "00:00";
                    countdownElement.classList.add('expired');
                    timerDisplay.classList.add('expired');
                    resendButton.disabled = false;
                    clearInterval(timerInterval);

                    verifyButton.disabled = true;
                    verifyButton.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>OTP Expired';
                    verifyButton.classList.add('btn-secondary');
                    verifyButton.classList.remove('btn-primary');
                } else {
                    timeLeft--;
                }
            }

            const timerInterval = setInterval(updateTimer, 1000);
            updateTimer();

            // OTP input handling
            if (otpInput) {
                otpInput.focus();

                otpInput.addEventListener('input', function (e) {
                    const value = this.value.replace(/\D/g, '');
                    this.value = value.slice(0, 6);

                    if (value.length === 6) {
                        otpFeedback.style.display = 'flex';
                        otpFeedback.className = 'input-feedback valid';
                        otpFeedback.innerHTML = '<i class="fas fa-check-circle"></i><span>Ready to verify</span>';
                        verifyButton.focus();
                    } else if (value.length > 0) {
                        otpFeedback.style.display = 'flex';
                        otpFeedback.className = 'input-feedback invalid';
                        otpFeedback.innerHTML = `<i class="fas fa-exclamation-circle"></i><span>Enter ${6 - value.length} more digits</span>`;
                    } else {
                        otpFeedback.style.display = 'none';
                    }
                });

                otpInput.addEventListener('keydown', function (e) {
                    if (!isNumberKey(e) && e.key !== 'Backspace' && e.key !== 'Delete' && e.key !== 'Tab') {
                        e.preventDefault();
                    }
                });

                otpInput.addEventListener('keyup', function (e) {
                    if (this.value.length === 6 && e.key !== 'Backspace' && e.key !== 'Delete') {
                        setTimeout(() => {
                            if (timeLeft > 0) {
                                verifyButton.click();
                            }
                        }, 300);
                    }
                });
            }

            function isNumberKey(evt) {
                const charCode = (evt.which) ? evt.which : evt.keyCode;
                return !(charCode > 31 && (charCode < 48 || charCode > 57));
            }

            if (resendButton) {
                resendButton.disabled = timeLeft > 0;
            }
        });

        function showLoading(button) {
            const originalText = button.innerHTML;
            button.innerHTML = '<span class="btn-spinner"></span> Processing...';
            button.disabled = true;

            setTimeout(() => {
                button.innerHTML = originalText;
                button.disabled = false;
            }, 5000);
        }

        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.href);
        }
    </script>
</body>
</html>

