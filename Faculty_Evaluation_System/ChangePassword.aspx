<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ChangePassword.aspx.vb" Inherits="Faculty_Evaluation_System.ChangePassword" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
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
            --text: #5a5c69;
        }
        body {
            background: linear-gradient(135deg, #f8f9fc 0%, #e9ecef 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 20px 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: var(--text);
            justify-content:center;
        }
        .password-container { position: relative; }
        .password-toggle {
            position: absolute; 
            right: 15px; 
            top: 42px;
            cursor: pointer; 
            color: var(--secondary); 
            z-index: 5;
        }
        .password-toggle:hover {
            color: var(--primary);
        }
        .card { 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 0.5rem 2rem rgba(58,59,69,0.15); 
            overflow: hidden;
            border: 1px solid #e3e6f0;
        }
        .card-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white; 
            text-align: center; 
            border-bottom: none; 
            padding: 2.5rem 2rem;
            position: relative;
        }
        .card-header::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--gold);
        }
        .card-body { 
            padding: 2.5rem; 
        }
        .form-control { 
            padding: 0.9rem 1.5rem; 
            border-radius: 10px; 
            border: 1px solid #d1d3e2;
            font-size: 1rem;
        }
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.3rem rgba(26, 58, 143, 0.25);
        }
        .btn-primary {
            background: linear-gradient(to right, var(--primary), var(--primary-light));
            border: none; 
            padding: 1rem; 
            font-weight: 600; 
            border-radius: 10px;
            font-size: 1.1rem;
            transition: all 0.3s;
            letter-spacing: 0.5px;
        }
        .btn-primary:hover {
            background: linear-gradient(to right, var(--primary-dark), var(--primary));
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .btn-gold {
            background: linear-gradient(to right, var(--gold), var(--gold-light));
            border: none; 
            padding: 1rem; 
            font-weight: 600; 
            border-radius: 10px;
            font-size: 1.1rem;
            transition: all 0.3s;
            letter-spacing: 0.5px;
            color: #333;
        }
        .btn-gold:hover {
            background: linear-gradient(to right, var(--gold-dark), var(--gold));
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            color: #333;
        }
        .password-strength { 
            height: 8px; 
            margin-top: 10px; 
            border-radius: 4px; 
            background: #e9ecef; 
        }
        .progress-bar { 
            border-radius: 4px; 
            transition: width 0.5s ease; 
        }
        .password-criteria { 
            font-size: 0.95rem; 
            color: var(--secondary); 
            margin-top: 10px;
            padding-left: 5px;
        }
        .criteria-met { color: var(--success); }
        .criteria-unmet { color: var(--danger); }
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            font-size: 1rem;
        }
        .back-btn {
            border-radius: 10px;
            padding: 0.7rem 1.8rem;
            font-size: 1rem;
            border: 1px solid var(--primary);
            color: var(--primary);
        }
        .back-btn:hover {
            background-color: var(--primary);
            color: white;
        }
        .form-label {
            font-size: 1.05rem;
            margin-bottom: 0.8rem;
            font-weight: 600;
            color: var(--primary);
        }
        
        /* Wider container */
        .wide-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .form-columns {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2.5rem;
        }
        
        /* Golden West specific styling */
        .gold-accent {
            color: var(--gold);
        }
        .text-primary {
            color: var(--primary) !important;
        }
        
        /* Security tips styling */
        .security-tips {
            background-color: #f8f9fc;
            border-radius: 12px;
            padding: 1.5rem;
            margin-top: 1.5rem;
            border-left: 4px solid var(--gold);
        }
        .security-tips h5 {
            color: var(--primary);
            margin-bottom: 1rem;
        }
        .security-tips ul {
            padding-left: 1.5rem;
            margin-bottom: 0;
        }
        .security-tips li {
            margin-bottom: 0.5rem;
            color: var(--secondary);
        }
        
        /* Info box styling */
        .info-box {
            background-color: #f0f4ff;
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px solid #e3e6f0;
        }
        .info-box h6 {
            color: var(--primary);
        }

        /* Responsive adjustments */
        @media (max-width: 992px) {
            .form-columns {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
        }
        @media (max-width: 768px) {
            .card-body {
                padding: 2rem 1.5rem;
            }
            .card-header {
                padding: 2rem 1.5rem;
            }
            .password-toggle {
                top: 40px;
            }
        }
        @media (max-width: 576px) {
            .card-body {
                padding: 1.5rem;
            }
            .card-header {
                padding: 1.5rem 1rem;
            }
            .password-toggle {
                top: 38px;
            }
        }
        
        /* Icon styling */
        .fa-lock, .fa-shield-alt, .fa-info-circle {
            color: var(--gold);
        }
        .fa-check-circle {
            color: var(--success);
        }
        .fa-times-circle {
            color: var(--secondary);
        }
        
        /* Logo styling */
        .logo {
            background: rgba(255, 255, 255, 0.2);
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            border: 2px solid var(--gold);
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="wide-container py-4">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10 col-xl-9">
                <div class="card">
                    <div class="card-header">
                        <div class="logo-container mb-3">
                            <div class="logo">
                                <i class="fas fa-lock fa-2x text-white"></i>
                            </div>
                        </div>
                        <h2 class="mb-2 text-white">Change Your Password</h2>
                        <p class="mb-0 text-white opacity-75 fs-5">Secure your account with a strong password</p>
                    </div>
                    
                    <div class="card-body">
                        <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none mb-4" />
                        
                        <div class="form-columns">
                            <!-- Left Column -->
                            <div>
                                <!-- Current password -->
                                <div class="mb-4 password-container">
                                    <label class="form-label"><i class="fas fa-key me-2 gold-accent"></i>Current Password</label>
                                    <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control"
                                                TextMode="Password" placeholder="Enter your current password" />
                                    <span class="password-toggle" onclick="togglePassword('<%= txtCurrentPassword.ClientID %>', 'eyeCurrent')">
                                        <i id="eyeCurrent" class="far fa-eye"></i>
                                    </span>
                                </div>

                                <!-- New password -->
                                <div class="mb-4 password-container">
                                    <label class="form-label"><i class="fas fa-lock me-2 gold-accent"></i>New Password</label>
                                    <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control"
                                                TextMode="Password" placeholder="Enter new password (min. 8 characters)"
                                                onkeyup="checkPasswordStrength(this.value)" />
                                    <span class="password-toggle" onclick="togglePassword('<%= txtNewPassword.ClientID %>', 'eyeNew')">
                                        <i id="eyeNew" class="far fa-eye"></i>
                                    </span>
                                    <div class="password-strength mt-3">
                                        <div id="passwordStrengthBar" class="progress-bar" style="width: 0%; height: 100%"></div>
                                    </div>
                                    <div class="password-criteria">
                                        <div id="lengthCheck"><i class="fas fa-circle me-2" style="font-size: 0.6rem;"></i> Minimum 8 characters</div>
                                    </div>
                                </div>

                                <!-- Confirm password -->
                                <div class="mb-4 password-container">
                                    <label class="form-label"><i class="fas fa-lock me-2 gold-accent"></i>Confirm New Password</label>
                                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control"
                                                TextMode="Password" placeholder="Confirm your new password"
                                                onkeyup="checkPasswordMatch()" />
                                    <span class="password-toggle" onclick="togglePassword('<%= txtConfirmPassword.ClientID %>', 'eyeConfirm')">
                                        <i id="eyeConfirm" class="far fa-eye"></i>
                                    </span>
                                    <div class="password-criteria">
                                        <div id="matchCheck"><i class="fas fa-circle me-2" style="font-size: 0.6rem;"></i> Passwords must match</div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Right Column -->
                            <div>
                                <div class="security-tips">
                                    <h5><i class="fas fa-shield-alt me-2 gold-accent"></i>Password Security Tips</h5>
                                    <ul>
                                        <li>Use at least 8 characters</li>
                                        <li>Don't use common words or personal information</li>
                                        <li>Consider using a passphrase instead of a password</li>
                                        <li>Avoid reusing passwords across different sites</li>
                                        <li>Change your password periodically</li>
                                    </ul>
                                </div>
                                
                                <div class="info-box mt-4">
                                    <h6><i class="fas fa-info-circle me-2 text-primary"></i>Did You Know?</h6>
                                    <p class="mb-0">This system uses secure encryption to protect your password. Your previous passwords cannot be reused for security reasons.</p>
                                </div>
                                
                                <div class="mt-4 p-3 bg-light rounded">
                                    <h6 class="text-primary">Password Requirements</h6>
                                    <div class="d-flex align-items-center mb-2">
                                        <i class="fas fa-check-circle text-success me-2"></i>
                                        <span>Minimum 8 characters in length</span>
                                    </div>
                                    <div class="d-flex align-items-center mb-2">
                                        <i class="fas fa-times-circle text-muted me-2"></i>
                                        <span>No complexity requirements</span>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <i class="fas fa-check-circle text-success me-2"></i>
                                        <span>Cannot be the same as your last password</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="d-grid mt-4">
                            <asp:Button ID="btnChangePassword" runat="server" Text="Update Password"
                                CssClass="btn btn-primary btn-lg py-3" OnClick="btnChangePassword_Click" />
                        </div>
                    </div>
                </div>

                <div class="text-center mt-4">
                    <a href="HRDashboard.aspx" class="btn btn-outline-secondary back-btn">
                        <i class="fas fa-arrow-left me-2"></i>Back to Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>
</form>

<script>
    function togglePassword(inputId, eyeIconId) {
        const passwordField = document.getElementById(inputId);
        const eyeIcon = document.getElementById(eyeIconId);
        if (passwordField.type === "password") {
            passwordField.type = "text";
            eyeIcon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            passwordField.type = "password";
            eyeIcon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }

    function checkPasswordStrength(password) {
        const strengthBar = document.getElementById('passwordStrengthBar');
        const lengthCheck = document.getElementById('lengthCheck');

        // Simplified to only check for minimum 8 characters
        if (password.length >= 8) {
            strengthBar.style.width = '100%';
            strengthBar.style.backgroundColor = 'var(--success)';
            lengthCheck.innerHTML = '<i class="fas fa-check-circle criteria-met me-2"></i> Minimum 8 characters';
            lengthCheck.className = 'password-criteria criteria-met';
        } else if (password.length > 0) {
            const strength = (password.length / 8) * 100;
            strengthBar.style.width = strength + '%';
            strengthBar.style.backgroundColor = 'var(--danger)';
            lengthCheck.innerHTML = '<i class="fas fa-times-circle criteria-unmet me-2"></i> Minimum 8 characters';
            lengthCheck.className = 'password-criteria criteria-unmet';
        } else {
            strengthBar.style.width = '0%';
            lengthCheck.innerHTML = '<i class="fas fa-circle me-2" style="font-size: 0.6rem;"></i> Minimum 8 characters';
            lengthCheck.className = 'password-criteria';
        }
    }

    function checkPasswordMatch() {
        const newPassword = document.getElementById('<%= txtNewPassword.ClientID %>').value;
        const confirmPassword = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
        const matchCheck = document.getElementById('matchCheck');
        
        if (confirmPassword.length === 0) {
            matchCheck.innerHTML = '<i class="fas fa-circle me-2" style="font-size: 0.6rem;"></i> Passwords must match';
            matchCheck.className = 'password-criteria';
        } else if (newPassword === confirmPassword) {
            matchCheck.innerHTML = '<i class="fas fa-check-circle criteria-met me-2"></i> Passwords match';
            matchCheck.className = 'password-criteria criteria-met';
        } else {
            matchCheck.innerHTML = '<i class="fas fa-times-circle criteria-unmet me-2"></i> Passwords do not match';
            matchCheck.className = 'password-criteria criteria-unmet';
        }
    }
    
    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        // Check if there's any existing password value
        const newPassword = document.getElementById('<%= txtNewPassword.ClientID %>').value;
        if (newPassword) {
            checkPasswordStrength(newPassword);
        }
        
        const confirmPassword = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
        if (confirmPassword) {
            checkPasswordMatch();
        }
    });
</script> 
</body>
</html>