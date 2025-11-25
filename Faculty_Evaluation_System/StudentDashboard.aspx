
<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="StudentDashboard.aspx.vb" Inherits="Faculty_Evaluation_System.StudentDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Student Dashboard - Faculty Evaluation System</title>
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
        --secondary: #6c757d;
        --success: #28a745;
        --info: #17a2b8;
        --warning: #ffc107;
        --danger: #dc3545;
        --light: #f8f9fa;
        --dark: #343a40;
        --gradient-primary: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
        --gradient-success: linear-gradient(135deg, var(--success) 0%, #1e7e34 100%);
        --gradient-info: linear-gradient(135deg, var(--info) 0%, #138496 100%);
    }
    
    body {
        background-color: #f8f9fc;
        min-height: 100vh;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        padding-bottom: 1rem;
    }
    
    /* Header styling */
    .header-bar {
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
        padding: 0.75rem 1rem;
        box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        margin-bottom: 1rem;
        border-radius: 0;
        border-bottom: 3px solid var(--gold);
    }
    
    .logo-section {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    
    .logo-container {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 0.4rem;
        padding: 0.3rem;
        flex-shrink: 0;
    }
    
    .logo-img {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
    }
    
    .title-section h2 {
        margin-bottom: 0.1rem;
        font-size: 1.1rem;
        color: white;
        font-weight: 700;
        line-height: 1.2;
    }
    
    .title-section small {
        color: rgba(255, 255, 255, 0.8);
        font-size: 0.7rem;
        line-height: 1;
    }
    
    /* Welcome Section - Mobile Optimized */
    .welcome-section {
        background: white;
        border-radius: 0.5rem;
        padding: 1rem;
        margin: 0.5rem 0.75rem 1rem 0.75rem;
        box-shadow: 0 0.15rem 1rem 0 rgba(58, 59, 69, 0.1);
        border-left: 4px solid var(--gold);
    }
    
    .welcome-icon {
        font-size: 1.3rem;
        color: var(--gold);
    }
    
    .student-name {
        font-size: 1rem;
        font-weight: 700;
        color: var(--primary);
        margin-bottom: 0.25rem;
    }
    
    .welcome-text {
        font-size: 0.75rem;
        color: var(--secondary);
        margin-bottom: 0.75rem;
    }
    
    /* Info Cards - Stack vertically on mobile */
    .info-cards-container {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
        margin-bottom: 1rem;
    }
    
    .info-card {
        border-radius: 0.4rem;
        padding: 0.75rem;
        background: white;
        box-shadow: 0 0.1rem 0.5rem 0 rgba(58, 59, 69, 0.1);
        border-left: 3px solid;
        transition: all 0.3s ease;
        border: 1px solid #e3e6f0;
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    
    .info-card.department { border-left-color: var(--primary); }
    .info-card.course { border-left-color: var(--success); }
    .info-card.class { border-left-color: var(--info); }
    
    .info-card-icon {
        font-size: 1.1rem;
        opacity: 0.8;
        flex-shrink: 0;
        width: 24px;
        text-align: center;
    }
    
    .info-card.department .info-card-icon { color: var(--primary); }
    .info-card.course .info-card-icon { color: var(--success); }
    .info-card.class .info-card-icon { color: var(--info); }
    
    .info-card-content {
        flex: 1;
    }
    
    .info-card-label {
        color: var(--secondary);
        font-size: 0.65rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 0.15rem;
        font-weight: 600;
    }
    
    .info-card-value {
        font-weight: 600;
        font-size: 0.8rem;
        color: #333;
        line-height: 1.2;
    }
    
    /* Stats Section - Side by side on mobile */
    .stats-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 0.5rem;
        margin-bottom: 1rem;
    }
    
    .stats-card {
        background: white;
        border-radius: 0.4rem;
        padding: 0.75rem;
        text-align: center;
        box-shadow: 0 0.1rem 0.5rem 0 rgba(58, 59, 69, 0.1);
        border: 1px solid #e3e6f0;
    }
    
    .stats-number {
        font-size: 1.1rem;
        font-weight: 700;
        margin-bottom: 0.15rem;
    }
    
    .stats-label {
        color: var(--secondary);
        font-size: 0.65rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-weight: 600;
    }
    
    /* Quick Action Section */
    .quick-action-section {
        margin: 0 0.75rem 1.5rem 0.75rem;
    }
    
    .quick-action-title {
        font-size: 1.2rem;
        font-weight: 700;
        margin-bottom: 1rem;
        color: var(--primary);
        display: flex;
        align-items: center;
        border-bottom: 2px solid var(--gold);
        padding-bottom: 0.5rem;
    }
    
    .quick-action-title i {
        margin-right: 0.5rem;
        font-size: 1.3rem;
        color: var(--gold);
    }
    
    .quick-action-grid {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }
    
    .quick-action-card {
        background: white;
        border-radius: 0.5rem;
        padding: 1.25rem;
        box-shadow: 0 0.15rem 1rem 0 rgba(58, 59, 69, 0.1);
        transition: all 0.3s ease;
        border: none;
    }
    
    .quick-action-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 0.3rem 1rem rgba(0, 0, 0, 0.15);
    }
    
    .action-icon {
        font-size: 1.75rem;
        margin-bottom: 0.75rem;
        color: var(--primary);
    }
    
    .action-title {
        font-size: 1.1rem;
        font-weight: 700;
        margin-bottom: 0.5rem;
        color: var(--primary);
    }
    
    .action-description {
        color: #666;
        margin-bottom: 1.25rem;
        line-height: 1.4;
        font-size: 0.85rem;
    }
    
    /* Buttons */
    .action-button {
        display: inline-block;
        background: var(--gradient-primary);
        color: white;
        padding: 0.75rem 1.25rem;
        border-radius: 0.5rem;
        text-decoration: none;
        font-weight: 600;
        font-size: 0.9rem;
        text-align: center;
        transition: all 0.3s ease;
        border: none;
        cursor: pointer;
        box-shadow: 0 0.2rem 0.5rem rgba(26, 58, 143, 0.3);
        width: 100%;
        min-height: 44px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .action-button:hover {
        transform: translateY(-1px);
        box-shadow: 0 0.3rem 0.75rem rgba(26, 58, 143, 0.4);
        color: white;
        text-decoration: none;
    }
    
    .action-button.secondary {
        background: var(--gradient-success);
        box-shadow: 0 0.2rem 0.5rem rgba(40, 167, 69, 0.3);
    }
    
    .action-button.secondary:hover {
        box-shadow: 0 0.3rem 0.75rem rgba(40, 167, 69, 0.4);
    }
    
    /* User dropdown */
    .user-dropdown {
        border: 1px solid rgba(255, 255, 255, 0.5);
        background: rgba(255, 255, 255, 0.1);
        color: white;
        border-radius: 0.4rem;
        padding: 0.4rem 0.75rem;
        font-size: 0.85rem;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 160px;
        min-height: 36px;
        display: flex;
        align-items: center;
    }
    
    .user-dropdown:hover {
        background: rgba(255, 255, 255, 0.2);
        border-color: var(--gold);
        color: white;
    }
    
    /* Mobile-first responsive design */
    @media (min-width: 576px) {
        .container {
            max-width: 100%;
            padding: 0 1rem;
        }
        
        .welcome-section {
            margin: 0.75rem 1rem 1.25rem 1rem;
            padding: 1.25rem;
        }
        
        .quick-action-section {
            margin: 0 1rem 2rem 1rem;
        }
    }
    
    @media (min-width: 768px) {
        body {
            padding-bottom: 2rem;
        }
        
        .header-bar {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 0 0 0.75rem 0.75rem;
        }
        
        .logo-container {
            width: 45px;
            height: 45px;
        }
        
        .title-section h2 {
            font-size: 1.3rem;
        }
        
        .title-section small {
            font-size: 0.8rem;
        }
        
        .welcome-section {
            margin: 0 0 1.5rem 0;
            padding: 1.5rem;
        }
        
        .student-name {
            font-size: 1.1rem;
        }
        
        .welcome-text {
            font-size: 0.85rem;
        }
        
        .info-cards-container {
            flex-direction: row;
            gap: 0.75rem;
        }
        
        .info-card {
            flex: 1;
            flex-direction: column;
            text-align: center;
            gap: 0.5rem;
            padding: 1rem 0.75rem;
        }
        
        .info-card-icon {
            font-size: 1.3rem;
            width: auto;
        }
        
        .stats-container {
            grid-template-columns: 1fr 1fr;
            gap: 0.75rem;
        }
        
        .stats-card {
            padding: 1rem;
        }
        
        .quick-action-section {
            margin: 0 0 2rem 0;
        }
        
        .quick-action-grid {
            flex-direction: row;
            gap: 1.25rem;
        }
        
        .quick-action-card {
            flex: 1;
            padding: 1.75rem;
        }
        
        .action-icon {
            font-size: 2.25rem;
        }
        
        .action-title {
            font-size: 1.2rem;
        }
        
        .action-description {
            font-size: 0.95rem;
        }
        
        .user-dropdown {
            max-width: 200px;
            padding: 0.5rem 0.875rem;
            font-size: 0.9rem;
        }
    }
    
    @media (min-width: 992px) {
        .container {
            max-width: 960px;
        }
    }
    
    @media (min-width: 1200px) {
        .container {
            max-width: 1140px;
        }
    }
    
    /* Very small phones */
    @media (max-width: 360px) {
        .header-bar {
            padding: 0.6rem 0.75rem;
        }
        
        .logo-container {
            width: 40px;
            height: 40px;
        }
        
        .title-section h2 {
            font-size: 1rem;
        }
        
        .title-section small {
            font-size: 0.65rem;
        }
        
        .welcome-section {
            margin: 0.5rem 0.5rem 1rem 0.5rem;
            padding: 0.875rem;
        }
        
        .quick-action-section {
            margin: 0 0.5rem 1.25rem 0.5rem;
        }
        
        .quick-action-card {
            padding: 1rem;
        }
        
        .user-dropdown {
            max-width: 140px;
            font-size: 0.8rem;
            padding: 0.35rem 0.6rem;
        }
    }
    
    /* Animation */
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .animate-card {
        animation: fadeInUp 0.6s ease-out;
    }
    
    /* Touch improvements */
    .btn, .action-button, .dropdown-toggle {
        -webkit-tap-highlight-color: transparent;
        touch-action: manipulation;
    }
    
    /* Prevent horizontal scrolling */
    html, body {
        max-width: 100%;
        overflow-x: hidden;
    }
    
    /* Safe area support for notched phones */
    @supports(padding: max(0px)) {
        .header-bar, .welcome-section, .quick-action-section {
            padding-left: max(1rem, env(safe-area-inset-left));
            padding-right: max(1rem, env(safe-area-inset-right));
        }
    }
</style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header-bar">
            <div class="d-flex justify-content-between align-items-center">
                <div class="logo-section">
                    <!-- Logo Container -->
                    <div class="logo-container">
                        <img src="Image/logo.png" alt="Faculty Evaluation System" class="logo-img" />
                    </div>
                    <div class="title-section">
                        <h2 class="mb-0 fw-bold">Golden West Colleges Inc.</h2>
                        <small>Faculty Evaluation System (Student Dashboard)</small>
                    </div>
                </div>
                <div class="dropdown">
                    <button class="btn user-dropdown dropdown-toggle d-flex align-items-center" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-person-circle me-2"></i>
                        <asp:Label ID="lblWelcome" runat="server" />
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow" aria-labelledby="userMenu">
                        <li><a class="dropdown-item" href="ChangePassword.aspx"><i class="bi bi-key me-2"></i>Change Password</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="Logout.aspx"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="container">
       
           <!-- Welcome Section - Mobile Optimized -->
<div class="welcome-section animate-card">
    <div class="d-flex align-items-center mb-3">
      
        <div>
            <div class="welcome-text">Welcome back!</div>
            <div class="student-name">
                <asp:Label ID="lblStudentName" runat="server" ></asp:Label>
            </div>
        </div>
    </div>
    
    <!-- Info Cards - Stack on mobile, row on tablet+ -->
    <div class="info-cards-container">
        <div class="info-card department">
            <i class="bi bi-building-gear info-card-icon"></i>
            <div class="info-card-content">
                <div class="info-card-label">Department</div>
                <div class="info-card-value">
                    <asp:Label ID="lblDepartment" runat="server"></asp:Label>
                </div>
            </div>
        </div>
        
        <div class="info-card course">
            <i class="bi bi-journal-bookmark info-card-icon"></i>
            <div class="info-card-content">
                <div class="info-card-label">Course</div>
                <div class="info-card-value">
                    <asp:Label ID="lblCourse" runat="server"></asp:Label>
                </div>
            </div>
        </div>
        
        <div class="info-card class">
            <i class="bi bi-people info-card-icon"></i>
            <div class="info-card-content">
                <div class="info-card-label">Class</div>
                <div class="info-card-value">
                    <asp:Label ID="lblClass" runat="server"></asp:Label>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Stats Cards -->
    <div class="stats-container">
        <div class="stats-card">
            <div class="stats-number text-danger">
                <asp:Label ID="lblPendingEvaluations" runat="server" Text="0" />
            </div>
            <div class="stats-label">Pending</div>
        </div>
        <div class="stats-card">
            <div class="stats-number text-success">
                <asp:Label ID="lblCompletedEvaluations" runat="server" Text="0" />
            </div>
            <div class="stats-label">Completed</div>
        </div>
    </div>
</div>

            <!-- Quick Actions Section -->
<div class="quick-action-section">
    <h5 class="quick-action-title">
        <i class="bi bi-lightning"></i>Quick Actions
    </h5>
    
    <div class="quick-action-grid">
        <!-- Faculty Evaluation Card -->
        <div class="quick-action-card animate-card" style="animation-delay: 0.1s;">
            <i class="bi bi-clipboard-check action-icon"></i>
            <h3 class="action-title">Faculty Evaluation</h3>
            <p class="action-description">
                Evaluate your faculty members and provide valuable feedback on their teaching performance and course delivery.
            </p>
            <a href="Evaluate.aspx" class="action-button">
                Start New Evaluation
            </a>
        </div>
        
        <!-- My Evaluations Card -->
        <div class="quick-action-card animate-card" style="animation-delay: 0.2s;">
            <i class="bi bi-list-check action-icon"></i>
            <h3 class="action-title">My Evaluations</h3>
            <p class="action-description">
                Review your previously submitted evaluations, track your feedback history, and monitor evaluation status.
            </p>
            <a href="MyEvaluations.aspx" class="action-button secondary">
                View My Evaluations
            </a>
        </div>
        
        <!-- Irregular Enrollment Card - Only visible for irregular students -->
        <div class="quick-action-card animate-card" style="animation-delay: 0.3s;" id="IrregularEnrollmentCard" runat="server" visible="false">
            <i class="bi bi-person-plus action-icon"></i>
            <h3 class="action-title">Irregular Enrollment</h3>
            <p class="action-description">
                Enroll in subjects for irregular students. Manage your subject enrollments and get approval from the Admin.
            </p>
            <a href="IrregularStudentEnrollment.aspx" class="action-button" style="background: var(--gradient-info);">
                Manage Enrollment
            </a>
        </div>
    </div>
</div>

        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Add animation on page load
        document.addEventListener('DOMContentLoaded', function () {
            const cards = document.querySelectorAll('.animate-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = (index * 0.1) + 's';
            });

            // Touch device improvements
            if ('ontouchstart' in window) {
                document.body.classList.add('touch-device');
            }
        });
    </script>
</body>
    </html>


