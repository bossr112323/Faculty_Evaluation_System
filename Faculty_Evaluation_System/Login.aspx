<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Login.aspx.vb" Inherits="Faculty_Evaluation_System.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <title>Login - Faculty Evaluation System</title>
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
      padding: 1rem;
  }

  .login-container {
      width: 100%;
      max-width: 460px;
      margin: 0 auto;
  }

  .logo-container {
      display: flex;
      align-items: center;
      margin-bottom: 1.5rem;
      border-radius: 16px;
      padding: 1rem 0;
      gap: 1rem;
  }

  .logo-placeholder {
      width: 90px;
      height: 90px;
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
      font-size: 1.4rem;
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
      font-size: 0.9rem;
      color: white;
      margin: 0.25rem 0 0 0;
      text-shadow: 0 1px 2px rgba(0,0,0,0.2);
  }

  .card {
      border: none;
      border-radius: 16px;
      box-shadow: 0 6px 25px rgba(0,0,0,0.1);
      overflow: hidden;
      backdrop-filter: blur(10px);
      background: rgba(255, 255, 255, 0.95);
      border: 1px solid #e3e6f0;
  }

  .card-body {
      padding: 1.5rem;
  }

  .form-label {
      font-weight: 600;
      margin-bottom: 0.5rem;
      color: var(--primary);
  }

  .form-control {
      padding: 0.75rem 1rem;
      border-radius: 8px;
      border: 1px solid #d1d3e2;
      transition: all 0.3s;
      font-size: 1rem;
  }

  .form-control:focus {
      border-color: var(--primary);
      box-shadow: 0 0 0 0.3rem rgba(26, 58, 143, 0.25);
  }

  .btn-primary {
      background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
      border: none;
      padding: 0.75rem;
      font-weight: 600;
      border-radius: 8px;
      transition: all 0.3s;
      font-size: 1rem;
  }

  .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 100%);
  }

  .btn-gold {
      background: linear-gradient(135deg, var(--gold) 0%, var(--gold-light) 100%);
      border: none;
      padding: 0.75rem;
      font-weight: 600;
      border-radius: 8px;
      transition: all 0.3s;
      font-size: 1rem;
      color: #333;
  }

  .btn-gold:hover {
      background: linear-gradient(135deg, var(--gold-dark) 0%, var(--gold) 100%);
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      color: #333;
  }

  .alert {
      display: none;
      border-radius: 8px;
      padding: 0.75rem 1rem;
  }

  .forgot-link {
      color: var(--primary);
      text-decoration: none;
      font-size: 0.9rem;
      transition: color 0.3s;
  }

  .forgot-link:hover {
      color: var(--primary-dark);
      text-decoration: underline;
  }

  .logo-placeholder img {
      width: 100%;
      height: auto;
      object-fit: contain;
      filter: drop-shadow(0 2px 4px rgba(0,0,0,0.2));
  }

  .footer {
      color: white;
      padding: 10px 15px;
      border-radius: 8px;
      margin-top: 20px;
      font-size: 0.85rem;
      text-align: center;
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(5px);
      border: 1px solid rgba(255, 255, 255, 0.2);
  }

  /* Password input group styles */
  .password-input-group {
      position: relative;
  }

  .toggle-password {
      position: absolute;
      right: 12px;
      top: 50%;
      transform: translateY(-50%);
      background: none;
      border: none;
      color: var(--secondary);
      cursor: pointer;
      padding: 0.25rem;
      transition: color 0.3s;
      z-index: 5;
  }

  .toggle-password:hover {
      color: var(--primary);
  }

  .toggle-password:focus {
      outline: none;
      color: var(--primary-dark);
  }

  /* Golden West specific styling */
  .gold-accent {
      color: var(--gold);
  }

 
  /* Icon styling */
  .fa-eye, .fa-eye-slash {
      color: var(--secondary);
  }

  .fa-eye:hover, .fa-eye-slash:hover {
      color: var(--primary);
  }

  /* Mobile-specific optimizations */
  @media (max-width: 576px) {
      body {
          padding: 0.5rem;
          align-items: flex-start;
          padding-top: 2rem;
      }
      
      .login-container {
          max-width: 100%;
          margin: 0 auto;
      }
      
      .logo-container {
          flex-direction: column;
          text-align: center;
          padding: 1rem 0;
          gap: 0.75rem;
      }
      
      .logo-placeholder {
          width: 70px;
          height: 70px;
          margin-bottom: 0;
      }
      
      .institution-name {
          font-size: 1.2rem;
      }
      
      .system-name {
          font-size: 0.85rem;
      }
      
      .card-body {
          padding: 1.25rem;
      }
      
      .form-control {
          padding: 0.875rem 1rem;
          font-size: 16px;
      }
      
      .btn-primary {
          padding: 0.875rem;
          font-size: 1rem;
      }
      
      .footer {
          font-size: 0.8rem;
          margin-top: 1.5rem;
          padding: 8px 12px;
      }
      
      .mb-3 {
          margin-bottom: 1rem !important;
      }
      
      .logo-container {
          margin-bottom: 1rem;
      }
      
      .toggle-password {
          right: 10px;
          padding: 0.2rem;
      }
  }

  /* Extra small devices */
  @media (max-width: 375px) {
      .logo-placeholder {
          width: 60px;
          height: 60px;
      }
      
      .institution-name {
          font-size: 1.1rem;
      }
      
      .card-body {
          padding: 1rem;
      }
      
      .form-control {
          padding: 0.75rem 0.875rem;
      }
      
      .btn-primary {
          padding: 0.75rem;
      }
      
      .footer {
          font-size: 0.75rem;
          padding: 6px 10px;
      }
      
      .toggle-password {
          right: 8px;
      }
  }

  /* Landscape orientation for mobile */
  @media (max-height: 600px) and (orientation: landscape) {
      body {
          padding: 0.5rem;
          align-items: flex-start;
      }
      
      .login-container {
          margin: 0.5rem auto;
      }
      
      .logo-container {
          margin-bottom: 1rem;
          padding: 0.75rem 0;
      }
      
      .logo-placeholder {
          width: 90px;
          height: 90px;
      }
      
      .institution-name {
          font-size: 1.1rem;
      }
  }

  /* Prevent horizontal scrolling */
  html, body {
      max-width: 100%;
      overflow-x: hidden;
  }

  /* Enhanced focus styles for accessibility */
  .btn-primary:focus,
  .form-control:focus,
  .forgot-link:focus {
      outline: 2px solid var(--primary);
      outline-offset: 2px;
  }

  /* Smooth transitions for all interactive elements */
  .logo-placeholder,
  .card,
  .btn-primary,
  .form-control {
      transition: all 0.3s ease;
  }

  /* Input group icons */
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
        .policy-modal .modal-content {
            border-radius: 16px;
            border: none;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .policy-modal .modal-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            border-radius: 16px 16px 0 0;
            border-bottom: 3px solid var(--gold);
        }

        .policy-modal .modal-title {
            font-weight: 700;
            font-size: 1.3rem;
        }

        .policy-modal .modal-body {
            max-height: 60vh;
            overflow-y: auto;
            padding: 1.5rem;
        }

        .policy-section {
            margin-bottom: 1.5rem;
        }

        .policy-section h6 {
            color: var(--primary);
            font-weight: 700;
            margin-bottom: 0.5rem;
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.25rem;
        }

        .policy-section ul {
            margin-bottom: 0;
            padding-left: 1.2rem;
        }

        .policy-section li {
            margin-bottom: 0.5rem;
            line-height: 1.5;
        }

        .footer-link {
            color: var(--gold) !important;
            text-decoration: none;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            border-bottom: 1px dotted var(--gold);
        }

        .footer-link:hover {
            color: var(--gold-light) !important;
            text-decoration: none;
            border-bottom: 1px solid var(--gold-light);
        }

        .footer {
            color: white;
            padding: 10px 15px;
            border-radius: 8px;
            margin-top: 20px;
            font-size: 0.85rem;
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(5px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            cursor: default;
        }

        .footer p {
            margin: 0;
        }

        /* Scrollbar styling for modal */
        .policy-modal .modal-body::-webkit-scrollbar {
            width: 6px;
        }

        .policy-modal .modal-body::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }

        .policy-modal .modal-body::-webkit-scrollbar-thumb {
            background: var(--primary);
            border-radius: 10px;
        }

        .policy-modal .modal-body::-webkit-scrollbar-thumb:hover {
            background: var(--primary-dark);
        }

        /* Mobile responsive adjustments for modal */
        @media (max-width: 576px) {
            .policy-modal .modal-dialog {
                margin: 1rem;
            }
            
            .policy-modal .modal-body {
                padding: 1rem;
                max-height: 50vh;
            }
            
            .policy-section {
                margin-bottom: 1rem;
            }
            
            .policy-section h6 {
                font-size: 0.95rem;
            }
            
            .policy-section li {
                font-size: 0.85rem;
            }
        }
    </style>
</head>
<body>
    <form id="frmLogin" runat="server">
        <div class="login-container">
            <!-- Logo and Institution Name -->
            <div class="logo-container">
                <div class="logo-placeholder">
                    <img src="image/gwc.png" alt="Golden West Colleges Logo" class="logo-img" />
                </div>
                <div class="institution-info">
                    <h1 class="institution-name">GOLDEN WEST COLLEGES INC.</h1>
                    <p class="system-name">Faculty Evaluation System</p>
                </div>
            </div>

            <!-- Login Card -->
            <div class="card">
                <div class="card-body">
                    <!-- Alert for messages -->
                    <asp:Label ID="lblMsg" runat="server" CssClass="alert d-block mb-3" />

                    <!-- School ID Field -->
                    <div class="mb-3 position-relative">
                        <label for="txtSchoolID" class="form-label">
                            <i class="fas fa-user me-2 gold-accent"></i>School ID
                        </label>
                        <div class="position-relative">
                            <i class="fas fa-id-card input-group-icon"></i>
                            <asp:TextBox ID="txtSchoolID" runat="server" CssClass="form-control input-with-icon" placeholder="Enter your school ID" />
                        </div>
                    </div>

                    <!-- Password Field -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <label for="txtPassword" class="form-label">
                                <i class="fas fa-lock me-2 gold-accent"></i>Password
                            </label>
                            <a href="ForgotPassword.aspx" class="forgot-link">Forgot Password?</a>
                        </div>
                        <div class="password-input-group">
                            <div class="position-relative">
                                <i class="fas fa-key input-group-icon"></i>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control input-with-icon" placeholder="Enter your password" />
                            </div>
                            <button type="button" class="toggle-password" id="togglePassword">
                                <i class="far fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Login Button -->
                    <div class="d-grid gap-2">
                        <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-primary" Text="Login" OnClick="btnLogin_Click" />
                    </div>
                </div>
            </div>

            <!-- Updated Footer Note with Clickable Policy -->
            <div class="footer text-center">
                <p>By logging in you agree to follow your institution's <span class="footer-link" data-bs-toggle="modal" data-bs-target="#policyModal">evaluation policy</span>.</p>
            </div>
        </div>

        <!-- Policy Modal -->
        <div class="modal fade policy-modal" id="policyModal" tabindex="-1" aria-labelledby="policyModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="policyModalLabel">
                            <i class="fas fa-file-contract me-2"></i>Faculty Evaluation System Policy
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <!-- Policy Content -->
                        <div class="policy-section">
                            <h6><i class="fas fa-user-graduate me-2"></i>Student Responsibilities</h6>
                            <ul>
                                <li>Provide honest and constructive feedback for all faculty evaluations</li>
                                <li>Complete evaluations within the specified timeframe</li>
                                <li>Maintain confidentiality of your login credentials</li>
                                <li>Evaluate faculty based on actual classroom experiences</li>
                                <li>Submit only one evaluation per faculty member per semester</li>
                            </ul>
                        </div>

                        <div class="policy-section">
                            <h6><i class="fas fa-chalkboard-teacher me-2"></i>Faculty Guidelines</h6>
                            <ul>
                                <li>Evaluation results are used for professional development purposes</li>
                                <li>Faculty may access aggregated results after evaluation periods close</li>
                                <li>Individual responses remain confidential and anonymous</li>
                                <li>Results contribute to continuous improvement of teaching quality</li>
                            </ul>
                        </div>

                        <div class="policy-section">
                            <h6><i class="fas fa-shield-alt me-2"></i>Data Privacy & Security</h6>
                            <ul>
                                <li>All evaluation data is stored securely and confidentially</li>
                                <li>Personal information is protected in accordance with data privacy laws</li>
                                <li>System access is monitored for security purposes</li>
                                <li>Unauthorized access or misuse of the system is prohibited</li>
                            </ul>
                        </div>

                        <div class="policy-section">
                            <h6><i class="fas fa-exclamation-triangle me-2"></i>Prohibited Activities</h6>
                            <ul>
                                <li>Sharing login credentials with others</li>
                                <li>Attempting to manipulate evaluation results</li>
                                <li>Submitting false or malicious evaluations</li>
                                <li>Accessing the system for unauthorized purposes</li>
                                <li>Violating institutional academic integrity policies</li>
                            </ul>
                        </div>
                        <div class="alert alert-info mt-3">
                            <i class="fas fa-info-circle me-2"></i>
                            <strong>Note:</strong> This policy is subject to updates. Users are responsible for reviewing the most current version available on the institution's official website.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-bs-dismiss="modal">
                            <i class="fas fa-check me-2"></i>I Understand
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </form>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Show Password Script -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const togglePassword = document.querySelector('#togglePassword');
            const passwordInput = document.querySelector('#<%= txtPassword.ClientID %>');
            const eyeIcon = togglePassword.querySelector('i');

            togglePassword.addEventListener('click', function () {
                // Toggle the password visibility
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);

                // Toggle the eye icon
                if (type === 'text') {
                    eyeIcon.classList.remove('fa-eye');
                    eyeIcon.classList.add('fa-eye-slash');
                    togglePassword.setAttribute('aria-label', 'Hide password');
                } else {
                    eyeIcon.classList.remove('fa-eye-slash');
                    eyeIcon.classList.add('fa-eye');
                    togglePassword.setAttribute('aria-label', 'Show password');
                }
            });

            // Add keyboard support for accessibility
            togglePassword.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    togglePassword.click();
                }
            });

            // Auto-focus on School ID field when page loads
            const schoolIDInput = document.querySelector('#<%= txtSchoolID.ClientID %>');
            if (schoolIDInput) {
                schoolIDInput.focus();
            }
        });
    </script>
</body>
</html>