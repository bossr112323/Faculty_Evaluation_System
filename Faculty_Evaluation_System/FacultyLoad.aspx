<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="FacultyLoad.aspx.vb" Inherits="Faculty_Evaluation_System.FacultyLoad" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Faculty Load Assignment - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- jQuery UI for Autocomplete -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/smoothness/jquery-ui.css">
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    
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
        --sidebar-width: 250px;
        --sidebar-collapsed-width: 80px;
        --header-height: 80px;
        --sidebar-bg: #1a3a8f;
        --sidebar-text: #ffffff;
        --sidebar-hover: #2a4aaf;
    }
    
    body {
        background-color: #f8f9fc;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        transition: all 0.3s ease;
    }
    
    /* Header styling with Golden West colors */
    .header-bar {
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
        padding: 1rem 1.5rem;
        box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        position: fixed;
        top: 0;
        right: 0;
        left: 0;
        z-index: 1000;
        height: var(--header-height);
        display: flex;
        align-items: center;
        justify-content: space-between;
        transition: all 0.3s ease;
        color: white;
        border-bottom: 3px solid var(--gold);
    }
    
    .header-bar .btn-outline-secondary,
    .header-bar .dropdown-toggle {
        border-color: rgba(255, 255, 255, 0.5);
        color: white;
        background-color: rgba(255, 255, 255, 0.1);
    }
    
    .header-bar .btn-outline-secondary:hover,
    .header-bar .dropdown-toggle:hover {
        background-color: rgba(255, 255, 255, 0.2);
        border-color: var(--gold);
        color: white;
    }
    
    /* Sidebar styling with Golden West colors */
    .sidebar {
        position: fixed;
        top: var(--header-height);
        left: 0;
        width: var(--sidebar-width);
        height: calc(100% - var(--header-height));
        overflow-y: auto;
        background: var(--sidebar-bg);
        box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        padding: 1rem 0;
        transition: all 0.3s ease;
        z-index: 999;
        border-right: 2px solid var(--gold);
    }
    
    .sidebar.collapsed {
        width: var(--sidebar-collapsed-width);
    }
    
    .sidebar .list-group-item {
        border: none;
        border-left: 4px solid transparent;
        border-radius: 0;
        padding: 0.75rem 1.5rem;
        color: var(--sidebar-text);
        font-weight: 500;
        white-space: nowrap;
        overflow: hidden;
        transition: all 0.3s ease;
        background-color: transparent;
    }
    
    .sidebar.collapsed .list-group-item {
        padding: 0.75rem 1rem;
        text-align: center;
    }
    
    .sidebar .list-group-item:hover,
    .sidebar .list-group-item.active {
        background-color: var(--sidebar-hover);
        color: white;
        border-left-color: var(--gold);
    }
    
    .sidebar .list-group-item i {
        margin-right: 0.5rem;
        width: 1.5rem;
        text-align: center;
        transition: margin 0.3s ease;
    }
    
    .sidebar.collapsed .list-group-item i {
        margin-right: 0;
        font-size: 1.25rem;
    }
    
    .sidebar .list-group-text {
        display: inline-block;
        transition: opacity 0.3s ease;
    }
    
    .sidebar.collapsed .list-group-text {
        opacity: 0;
        width: 0;
        height: 0;
        overflow: hidden;
        display: none;
    }
    
    /* Main content */
    .content {
        margin-left: var(--sidebar-width);
        margin-top: var(--header-height);
        padding: 1.5rem;
        transition: all 0.3s ease;
    }
    
    .content.collapsed {
        margin-left: var(--sidebar-collapsed-width);
    }
    
    /* Card styling with Golden West accents */
    .card {
        border: none;
        border-radius: 0.35rem;
        box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
        margin-bottom: 1.5rem;
    }
    
    .card-header {
        background-color: #f8f9fc;
        border-bottom: 1px solid #e3e6f0;
        padding: 0.75rem 1.25rem;
        font-weight: 700;
    }
    
    /* Button styling with Golden West colors */
    .btn-primary {
        background-color: var(--primary);
        border-color: var(--primary);
    }
    
    .btn-primary:hover {
        background-color: var(--primary-dark);
        border-color: var(--primary-dark);
    }
    
    .btn-outline-primary {
        color: var(--primary);
        border-color: var(--primary);
    }
    
    .btn-outline-primary:hover {
        background-color: var(--primary);
        color: white;
    }
    
    .btn-gold {
        background-color: var(--gold);
        border-color: var(--gold);
        color: #333;
    }
    
    .btn-gold:hover {
        background-color: var(--gold-dark);
        border-color: var(--gold-dark);
        color: #333;
    }
    
    /* Table styling */
    .table th {
        border-top: none;
        font-weight: 700;
        color: var(--dark);
        background-color: #f8f9fc;
    }
    
    /* Form controls */
    .form-control:focus, .form-select:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
    }
    
    /* Sidebar toggler with Golden West colors */
    .sidebar-toggler {
        display: block !important;
        position: fixed;
        bottom: 20px;
        left: 20px;
        z-index: 1000;
        background: var(--gold);
        color: #333;
        border: none;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.3);
        transition: all 0.3s ease;
    }
    
    .sidebar-toggler:hover {
        background: var(--gold-dark);
        transform: rotate(180deg);
    }
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
        .sidebar {
            left: calc(-1 * var(--sidebar-width));
            width: var(--sidebar-width);
        }
        
        .sidebar.mobile-show {
            left: 0;
        }
        
        .content {
            margin-left: 0;
            padding: 1rem;
        }
        
        .content.collapsed {
            margin-left: 0;
        }
        
        .header-title {
            font-size: 1.25rem;
        }
        
        .sidebar-toggler {
            left: 10px;
            bottom: 10px;
        }
        
        .header-bar {
            padding: 0.75rem 1rem;
        }
        
        .header-bar .title-section h3 {
            font-size: 1.2rem;
        }
        
        .header-bar .title-section small {
            font-size: 0.75rem;
        }
        
        .header-bar .dropdown-toggle {
            padding: 0.375rem 0.5rem;
            font-size: 0.875rem;
        }
        
        .header-bar .btn-outline-primary {
            padding: 0.375rem 0.5rem;
        }
        
        /* Mobile table adjustments */
        .table-responsive {
            font-size: 0.875rem;
        }
        
        .table-responsive .btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
        }
        
        /* Page header adjustments */
        .page-header {
            flex-direction: column;
            align-items: flex-start !important;
        }
        
        .page-header .btn {
            margin-top: 0.5rem;
            align-self: flex-end;
        }
        
        /* Form adjustments */
        .form-section .row {
            flex-direction: column;
        }
        
        .form-section .col-md-4 {
            width: 100%;
            margin-bottom: 1rem;
        }
        
        .form-section .btn {
            width: 100%;
        }
    }
    
    /* Animation for alerts */
    .alert-slide {
        animation: slideIn 0.5s forwards;
    }
    
    @keyframes slideIn {
        from {
            transform: translateY(-20px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
    
    /* Section headers in sidebar when collapsed */
    .sidebar-header {
        padding: 0.5rem 1.5rem;
        font-size: 0.7rem;
        text-transform: uppercase;
        color: rgba(255, 255, 255, 0.7);
        font-weight: 800;
        transition: all 0.3s ease;
    }
    
    .sidebar.collapsed .sidebar-header {
        opacity: 0;
        height: 0;
        padding: 0;
        margin: 0;
        overflow: hidden;
    }
    
    /* Logo styling */
    .header-logo {
        height: 40px;
        width: auto;
        object-fit: contain;
        max-width: 150px;
    }
    
    /* Mobile sidebar overlay */
    .sidebar-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 998;
        display: none;
    }
    
    .sidebar-overlay.show {
        display: block;
    }
    
    /* Mobile adjustments for better touch targets */
    @media (max-width: 768px) {
        .sidebar .list-group-item {
            padding: 1rem 1.5rem;
        }
        
        .btn {
            padding: 0.5rem 0.75rem;
        }
        
        .card-body {
            padding: 1rem;
        }
        
        /* Table row adjustments */
        .table-responsive {
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
        }
        
        /* GridView action buttons */
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        
        .action-buttons .btn {
            margin-bottom: 0.25rem;
        }
    }
    
    /* Mobile menu button styling */
    #mobileSidebarToggler {
        background: rgba(255, 255, 255, 0.2);
        border-color: rgba(255, 255, 255, 0.5);
        color: white;
    }
    
    #mobileSidebarToggler:hover {
        background: rgba(255, 255, 255, 0.3);
    }
    
    /* Table row hover effect */
    .table-hover tbody tr:hover {
        background-color: rgba(26, 58, 143, 0.05);
    }
    
    /* Form section styling */
    .form-section {
        background-color: #f8f9fc;
        border-radius: 0.35rem;
        padding: 1.5rem;
    }
    
    .form-section-title {
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--primary);
        margin-bottom: 1rem;
        padding-bottom: 0.5rem;
        border-bottom: 1px solid #e3e6f0;
    }
    
    .form-row-spaced {
        margin-bottom: 1rem;
    }
    
    /* Floating action button */
    .floating-action-btn {
        position: fixed;
        bottom: 30px;
        right: 30px;
        z-index: 1000;
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        border-radius: 50%;
        width: 60px;
        height: 60px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        background-color: var(--primary);
        border-color: var(--primary);
    }
    
    .floating-action-btn:hover {
        background-color: var(--primary-dark);
        border-color: var(--primary-dark);
    }
    
    /* Add autocomplete specific styles */
    .ui-autocomplete {
        max-height: 200px;
        overflow-y: auto;
        overflow-x: hidden;
        z-index: 10000;
        background-color: white;
        border: 1px solid #ccc;
        border-radius: 4px;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    .ui-menu-item {
        padding: 8px 12px;
        cursor: pointer;
        border-bottom: 1px solid #f0f0f0;
    }
    
    .ui-menu-item:last-child {
        border-bottom: none;
    }
    
    .ui-menu-item:hover {
        background-color: #f8f9fa;
    }
    
    .ui-state-focus {
        background-color: var(--primary) !important;
        color: white !important;
    }
    
    .autocomplete-loading {
        background: white url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nMTYnIGhlaWdodD0nMTYnIHZpZXdCb3g9JzAgMCAxNiAxNicgZmlsbD0nbm9uZScgeG1sbnM9J2h0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnJz48Y2lyY2xlIGN4PSc4JyBjeT0nOCcgcj0nNycgc3Ryb2tlPScjN2E4MmFkJyBzdHJva2Utb3BhY2l0eT0nMC4zJyBzdHJva2Utd2lkdGg9JzEuNSc+PC9jaXJjbGU+PHBhdGggZD0nTTggMTVBNyA3IDAgMSAxIDggMScgc3Ryb2tlPScjMWEzYTlmJyBzdHJva2Utd2lkdGg9JzEuNSc+PC9wYXRoPjwvc3ZnPg==') right center no-repeat;
        background-size: 16px 16px;
    }
    
    .autocomplete-container {
        position: relative;
    }
    
    /* Modal backdrop fix for autopostback */
    .modal-backdrop {
        z-index: 1040;
    }
    
    .modal {
        z-index: 1050;
    }
    
    /* Modal header styling */
    .modal-header.bg-primary {
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%) !important;
        border-bottom: 2px solid var(--gold);
    }
    
    /* Search container for mobile */
    .search-container {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
    }
    
    @media (max-width: 768px) {
        .search-container {
            flex-direction: column;
        }
        
        .search-container .input-group {
            width: 100%;
        }
    }
    
    /* Golden West specific styling */
    .page-title {
        color: var(--primary);
        border-bottom: 2px solid var(--gold);
        padding-bottom: 0.5rem;
    }
    
    .gold-accent {
        color: var(--gold);
    }
    
    /* Card header improvements */
    .card-header h5 {
        color: var(--primary);
    }
    
    /* Button improvements */
    .btn-warning {
        background-color: var(--gold);
        border-color: var(--gold);
        color: #333;
    }
    
    .btn-warning:hover {
        background-color: var(--gold-dark);
        border-color: var(--gold-dark);
        color: #333;
    }
    
    /* Search button styling */
    .btn-secondary {
        background-color: var(--primary-light);
        border-color: var(--primary-light);
        color: white;
    }
    
    .btn-secondary:hover {
        background-color: var(--primary);
        border-color: var(--primary);
        color: white;
    }
    
    /* Faculty load card styling */
    .faculty-card {
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    
    .faculty-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
    }
    /* Sidebar badge positioning - FIXED */
.sidebar .list-group-item {
    position: relative;
    padding-right: 3.5rem !important;
}

.sidebar.collapsed .list-group-item {
    padding-right: 2rem !important;
}

.sidebar .badge {
    font-size: 0.65rem;
    padding: 0.25rem 0.4rem;
    min-width: 1.5rem;
    height: 1.5rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    position: absolute;
    top: 8px;
    right: 12px;
    transform: none !important;
    z-index: 1000;
}

.sidebar.collapsed .badge {
    top: 6px !important;
    right: 8px !important;
}
    .faculty-card {
        transition: all 0.3s ease;
        border-left: 4px solid #1a3a8f;
    }
    
    .faculty-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        border-left-color: #d4af37;
    }
    
    .subject-count-badge {
        font-size: 1.1rem;
        padding: 0.5rem 0.75rem;
    }
    
    /* Details Modal Styles */
    .details-modal .modal-lg {
        max-width: 90%;
    }
    
    .faculty-details-header {
        background: linear-gradient(135deg, #1a3a8f 0%, #2a4aaf 100%);
        color: white;
        padding: 1.5rem;
        border-bottom: 3px solid #d4af37;
    }
    
    .assignment-card {
        border: 1px solid #e3e6f0;
        border-radius: 0.35rem;
        margin-bottom: 1rem;
        transition: all 0.3s ease;
    }
    
    .assignment-card:hover {
        border-color: #1a3a8f;
        box-shadow: 0 0.25rem 0.5rem rgba(0, 0, 0, 0.1);
    }
    
    .assignment-header {
        background-color: #f8f9fc;
        padding: 1rem;
        border-bottom: 1px solid #e3e6f0;
        font-weight: 600;
        color: #1a3a8f;
    }
    
    .assignment-body {
        padding: 1rem;
    }
    
    .info-row {
        display: flex;
        margin-bottom: 0.5rem;
        align-items: center;
    }
    
    .info-label {
        font-weight: 600;
        min-width: 120px;
        color: #6c757d;
    }
    
    .info-value {
        color: #343a40;
    }
    
    /* Action buttons in details view */
    .action-buttons {
        display: flex;
        gap: 0.5rem;
        flex-wrap: wrap;
    }
    
    @media (max-width: 768px) {
        .action-buttons {
            flex-direction: column;
        }
        
        .action-buttons .btn {
            margin-bottom: 0.25rem;
        }
        
        .info-row {
            flex-direction: column;
            align-items: flex-start;
        }
        
        .info-label {
            min-width: auto;
            margin-bottom: 0.25rem;
        }
    }


</style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />
        
        <!-- Header -->
        <div class="header-bar">
            <div class="d-flex align-items-center">
                <button id="mobileSidebarToggler" class="btn btn-sm btn-outline-secondary me-2 d-lg-none" type="button">
                    <i class="bi bi-list"></i>
                </button>
                <!-- Logo Section -->
                <div class="d-flex align-items-center me-3">
                    <img src="Image/logo.png" alt="GWC Logo" class="header-logo me-2" 
                         style="height: 40px; width: auto; object-fit: contain;" 
                         onerror="this.style.display='none'" />
                    <div class="title-section">
                        <h3 class="mb-0 fw-bold text-white">Golden West Colleges Inc.</h3>
                         <small class="text-white-50">Faculty Evaluation System (Admin Dashboard)</small>
                    </div>
                </div>
            </div>
            <div class="d-flex align-items-center">
                <div class="dropdown">
                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-person-circle me-1"></i>
                        <span class="d-none d-sm-inline"><asp:Label ID="lblWelcome" runat="server" /></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
                        <li><a class="dropdown-item" href="ChangePassword.aspx"><i class="bi bi-key me-2"></i>Change Password</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="Logout.aspx"><i class="bi bi-box-arrow-right me-2"></i>Logout</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Sidebar Overlay for Mobile -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <h6 class="sidebar-header px-3 text-uppercase">Main Navigation</h6>
            <div class="list-group list-group-flush">
                <a href="HRDashboard.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-speedometer2"></i>
                    <span class="list-group-text">Dashboard</span>
                </a>
                <h6 class="sidebar-header px-3 text-uppercase">User Management</h6>
                <a href="Users.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-people"></i>
                    <span class="list-group-text">Manage Users</span>
                </a>
                <a href="Students.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-person-badge"></i>
                    <span class="list-group-text">Manage Students</span>
                </a>
                <h6 class="sidebar-header px-3 text-uppercase">Academic Management</h6>
                <a href="Departments.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-building-gear"></i>
                    <span class="list-group-text">Manage Departments</span>
                </a>
                <a href="Courses.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-journal-bookmark"></i>
                    <span class="list-group-text">Manage Courses</span>
                </a>
                <a href="Classes.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-collection"></i>
                    <span class="list-group-text">Manage Classes</span>
                </a>
                <a href="Subjects.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-journals"></i>
                    <span class="list-group-text">Manage Subjects</span>
                </a>
                <a href="FacultyLoad.aspx" class="list-group-item list-group-item-action active">
                    <i class="bi bi-diagram-3"></i>
                    <span class="list-group-text">Manage Faculty Load</span>
                </a>
                <a href="AdminConfirmEnrollment.aspx" class="list-group-item list-group-item-action position-relative">
                    <i class="bi bi-person-check"></i>
                    <span class="list-group-text">Approve Enrollments</span>
                    <asp:Label ID="sidebarEnrollmentBadge" runat="server" 
                              CssClass="badge bg-danger rounded-pill"
                              Visible="false"></asp:Label>
                </a>
                <h6 class="sidebar-header px-3 text-uppercase">Evaluation Management</h6>
                <a href="Questions.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-question-circle"></i>
                    <span class="list-group-text">Manage Questions</span>
                </a>
                <a href="EvaluationCycles.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-arrow-repeat"></i>
                    <span class="list-group-text">Manage Evaluation Cycles</span>
                </a>
              
                <h6 class="sidebar-header px-3 text-uppercase">Report & Analytics</h6>
                <a href="Reports.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-graph-up"></i>
                    <span class="list-group-text">Analytics</span>
                </a>
              <a href="ReleaseResults.aspx" class="list-group-item list-group-item-action position-relative">
                    <i class="bi bi-send-check"></i>
                    <span class="list-group-text">Release Results</span>
                    <asp:Label ID="sidebarReleaseBadge" runat="server" 
                              CssClass="badge bg-danger rounded-pill"
                              Visible="false"></asp:Label>
                </a>
                <a href="Prints.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-printer"></i>
                    <span class="list-group-text">Reports</span>
                </a>
            </div>
            
            <button id="sidebarToggler" class="sidebar-toggler d-none d-lg-block">
                <i class="bi bi-arrow-left-circle"></i>
            </button>
        </div>

        <!-- Main Content -->
        <div class="content" id="mainContent">
            <!-- Alert Message -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none mb-3 alert-slide" />
            
            <!-- Page Title -->
            <div class="d-flex justify-content-between align-items-center mb-4 page-header">
                <h2 class="mb-0 page-title"><i class="bi bi-diagram-3 me-2 gold-accent"></i>Manage Faculty Load</h2>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnExport" runat="server" CssClass="btn btn-info text-white" OnClick="btnExport_Click">
                        <i class="bi bi-download me-1"></i>Export CSV
                    </asp:LinkButton>
                    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#importModal">
                        <i class="bi bi-upload me-1"></i>Import CSV
                    </button>
                    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#assignFacultyModal">
                        <i class="bi bi-person-plus me-1"></i>Assign Faculty Load
                    </button>
                </div>
            </div>

            <!-- Assign Faculty Modal -->
            <div class="modal fade" id="assignFacultyModal" tabindex="-1" aria-labelledby="assignFacultyModalLabel" aria-hidden="true" data-bs-backdrop="static">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title" id="assignFacultyModalLabel">
                                <i class="bi bi-person-plus me-2"></i>Assign Faculty Load
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:UpdatePanel ID="updAssignFaculty" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                                <ContentTemplate>
                                    <!-- Academic Information -->
                                    <div class="form-section">
                                        <div class="form-section-title">Academic Information</div>
                                        <div class="row g-3 form-row-spaced">
                                            <div class="col-md-6">
                                                <label class="form-label fw-semibold">Course <span class="text-danger">*</span></label>
                                                <asp:DropDownList ID="ddlCourses" runat="server" CssClass="form-select"
                                                    AutoPostBack="True" OnSelectedIndexChanged="ddlCourses_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label fw-semibold">Year Level <span class="text-danger">*</span></label>
                                                <asp:DropDownList ID="ddlYearLevel" runat="server" CssClass="form-select"
                                                    AutoPostBack="True" OnSelectedIndexChanged="ddlYearLevel_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label fw-semibold">Section <span class="text-danger">*</span></label>
                                                <div class="autocomplete-container">
                                                    <asp:TextBox ID="txtSection" runat="server" CssClass="form-control" 
                                                        placeholder="Type section name..." AutoPostBack="false" />
                                                    <asp:HiddenField ID="hfSectionValue" runat="server" />
                                                </div>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label fw-semibold">Semester <span class="text-danger">*</span></label>
                                                <asp:DropDownList ID="ddlTerm" runat="server" CssClass="form-select">
                                                    <asp:ListItem Text="1st Semester" Value="1st Semester"></asp:ListItem>
                                                    <asp:ListItem Text="2nd Semester" Value="2nd Semester"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Assignment Details -->
                                    <div class="form-section">
                                        <div class="form-section-title">Assignment Details</div>
                                        <div class="row g-3 form-row-spaced">
                                            <div class="col-md-6">
                                                <label class="form-label fw-semibold">Faculty Member <span class="text-danger">*</span></label>
                                                <div class="autocomplete-container">
                                                    <asp:TextBox ID="txtFaculty" runat="server" CssClass="form-control" 
                                                        placeholder="Type faculty name..." AutoPostBack="false" />
                                                    <asp:HiddenField ID="hfFacultyID" runat="server" />
                                                </div>
                                            </div>

                                            <div class="col-md-6">
                                                <label class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
                                                <div class="autocomplete-container">
                                                    <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" 
                                                        placeholder="Type subject name..." AutoPostBack="false" />
                                                    <asp:HiddenField ID="hfSubjectID" runat="server" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Modal-specific message area -->
                                    <asp:Label ID="lblModalMessage" runat="server" CssClass="alert d-none mb-3" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="ddlCourses" EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="ddlYearLevel" EventName="SelectedIndexChanged" />
                                    <asp:PostBackTrigger ControlID="btnAssign" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </div>
                        <div class="modal-footer">
    <asp:Button ID="btnAssign" runat="server" Text="Assign Faculty" CssClass="btn btn-primary px-4" OnClick="btnAssign_Click" />
    <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Cancel</button>
</div>
                    </div>
                </div>
            </div>
            <!-- Edit Faculty Load Modal -->
<div class="modal fade" id="editFacultyLoadModal" tabindex="-1" aria-labelledby="editFacultyLoadModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title" id="editFacultyLoadModalLabel">
                    <i class="bi bi-pencil-square me-2"></i>Edit Faculty Load Assignment
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
               <asp:UpdatePanel ID="updEditFaculty" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
                        <asp:HiddenField ID="hfEditLoadID" runat="server" />
                        
                        <!-- Academic Information -->
                        <div class="form-section">
                            <div class="form-section-title">Academic Information</div>
                            <div class="row g-3 form-row-spaced">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Course <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlEditModalCourse" runat="server" CssClass="form-select"
                                        AutoPostBack="True" OnSelectedIndexChanged="ddlEditModalCourse_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Year Level <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlEditModalYearLevel" runat="server" CssClass="form-select"
                                        AutoPostBack="True" OnSelectedIndexChanged="ddlEditModalYearLevel_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Section <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlEditModalSection" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Semester <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlEditModalTerm" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="1st Semester" Value="1st Semester"></asp:ListItem>
                                        <asp:ListItem Text="2nd Semester" Value="2nd Semester"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>

                        <!-- Assignment Details -->
                        <div class="form-section">
                            <div class="form-section-title">Assignment Details</div>
                            <div class="row g-3 form-row-spaced">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Faculty Member</label>
                                    <asp:TextBox ID="txtEditModalFaculty" runat="server" CssClass="form-control" 
                                        ReadOnly="true" BackColor="#f8f9fa" />
                                    <asp:HiddenField ID="hfEditModalFacultyID" runat="server" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
                                    <asp:DropDownList ID="ddlEditModalSubject" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>

                        <!-- Edit Modal Message -->
                        <asp:Label ID="lblEditModalMessage" runat="server" CssClass="alert d-none mb-3" />
                    </ContentTemplate>
    <Triggers>
        <asp:AsyncPostBackTrigger ControlID="gvFacultyDetails" EventName="RowCommand" />
        <asp:AsyncPostBackTrigger ControlID="ddlEditModalCourse" EventName="SelectedIndexChanged" />
        <asp:AsyncPostBackTrigger ControlID="ddlEditModalYearLevel" EventName="SelectedIndexChanged" />
        <asp:PostBackTrigger ControlID="btnUpdateAssignment" />
    </Triggers>
</asp:UpdatePanel>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnUpdateAssignment" runat="server" Text="Update Assignment" 
                    CssClass="btn btn-warning px-4" OnClick="btnUpdateAssignment_Click" />
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>
            <!-- Import Modal -->
            <div class="modal fade" id="importModal" tabindex="-1" aria-labelledby="importModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title" id="importModalLabel">
                                <i class="bi bi-upload me-2"></i>Import Faculty Load from CSV
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:UpdatePanel ID="updImport" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <!-- Download Template -->
                                    <div class="alert alert-info">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <h6><i class="bi bi-info-circle me-2"></i>Import Instructions</h6>
                                                <ul class="mb-2 small">
                                                    <li><strong>Required fields:</strong> FacultyName, Course, SubjectCode, YearLevel, Section, Term</li>
                                                    <li><strong>Optional fields:</strong> SubjectName</li>
                                                    <li><strong>Duplicate handling:</strong> Active assignments are skipped, deleted assignments are reactivated</li>
                                                    <li><strong>Auto-creation:</strong> Missing subjects and classes are created automatically</li>
                                                </ul>
                                            </div>
                                            <asp:Button ID="btnDownloadTemplate" runat="server" Text="Download Template" 
                                                CssClass="btn btn-outline-primary btn-sm" OnClick="btnDownloadTemplate_Click" />
                                        </div>
                                    </div>

                                    <!-- File Upload -->
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Select CSV File <span class="text-danger">*</span></label>
                                        <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" 
                                            accept=".csv" />
                                        <div class="form-text">Maximum file size: 10MB. File must be in CSV format.</div>
                                    </div>

                                    <!-- Import Options -->
                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Import Options</label>
                                        <div class="form-check">
                                            <asp:CheckBox ID="chkSkipErrors" runat="server" CssClass="form-check-input" Checked="true" />
                                            <label class="form-check-label" for="<%= chkSkipErrors.ClientID %>">
                                                Continue importing when errors occur (skip problematic rows)
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <asp:CheckBox ID="chkCreateMissing" runat="server" CssClass="form-check-input" Checked="true" />
                                            <label class="form-check-label" for="<%= chkCreateMissing.ClientID %>">
                                                Automatically create missing subjects and classes
                                            </label>
                                        </div>
                                    </div>

                                    <!-- Results Display -->
                                    <asp:Panel ID="pnlImportResults" runat="server" Visible="false" CssClass="mt-3">
                                        <div class="alert alert-info">
                                            <h6><i class="bi bi-check-circle me-2"></i>Import Results</h6>
                                            <asp:Literal ID="litImportResults" runat="server" />
                                        </div>
                                    </asp:Panel>

                                    <!-- Import Message -->
                                    <asp:Label ID="lblImportMessage" runat="server" CssClass="alert d-none mb-3" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:PostBackTrigger ControlID="btnImport" />
                                    <asp:PostBackTrigger ControlID="btnDownloadTemplate" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </div>
                        <div class="modal-footer">
                            <asp:Button ID="btnImport" runat="server" Text="Start Import" 
                                CssClass="btn btn-success px-4" OnClick="btnImport_Click" />
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" onclick="resetImportForm()">Cancel</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Faculty Details Modal -->
            <div class="modal fade details-modal" id="facultyDetailsModal" tabindex="-1" aria-labelledby="facultyDetailsModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="faculty-details-header">
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="modal-title mb-0" id="facultyDetailsModalLabel">
                                    <i class="bi bi-person-video3 me-2"></i>
                                    <asp:Label ID="lblFacultyDetailsTitle" runat="server" Text="Faculty Subject Assignments" />
                                </h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                        </div>
                        <div class="modal-body">
                            <asp:UpdatePanel ID="updFacultyDetails" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div class="table-responsive">
                                <asp:GridView ID="gvFacultyDetails" runat="server"
    CssClass="table table-striped table-bordered table-hover"
    AutoGenerateColumns="False"
    DataKeyNames="LoadID,FacultyID,SubjectID,CourseID,ClassID,YearLevel,Section,Term"
    OnRowCommand="gvFacultyDetails_RowCommand"
    OnRowDeleting="gvFacultyDetails_RowDeleting"
    EmptyDataText="No subject assignments found for this faculty member.">
    
    <Columns>
        <asp:BoundField DataField="LoadID" HeaderText="ID" ReadOnly="True" Visible="false" />
        
        <asp:TemplateField HeaderText="Subject">
            <ItemTemplate>
                <div class="fw-semibold text-primary"><%# Eval("SubjectName") %></div>
                <small class="text-muted"><%# Eval("SubjectCode") %></small>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Course & Class">
            <ItemTemplate>
                <div class="fw-semibold"><%# Eval("CourseName") %></div>
                <small class="text-muted"><%# Eval("YearLevel") %> - <%# Eval("Section") %></small>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Semester">
            <ItemTemplate>
                <span class="badge bg-info"><%# Eval("Term") %></span>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
                <div class="action-buttons">
                    <asp:LinkButton ID="btnEdit" runat="server" 
                        CommandName="EditRecord" 
                        CommandArgument='<%# Eval("LoadID") %>'
                        CssClass="btn btn-sm btn-warning">
                        <i class="bi bi-pencil"></i> Edit
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete"
                        CssClass="btn btn-sm btn-danger"
                        OnClientClick="return confirm('Are you sure you want to delete this faculty assignment?');">
                        <i class="bi bi-trash"></i> Delete
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>
</asp:GridView>
                                    </div>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="gvFacultyDetails" EventName="RowEditing" />
                                    <asp:AsyncPostBackTrigger ControlID="gvFacultyDetails" EventName="RowUpdating" />
                                    <asp:AsyncPostBackTrigger ControlID="gvFacultyDetails" EventName="RowCancelingEdit" />
                                    <asp:AsyncPostBackTrigger ControlID="gvFacultyDetails" EventName="RowDeleting" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Faculty Summary Section -->
            <div class="card">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h5 class="m-0 fw-bold text-primary"><i class="bi bi-people me-2"></i>Faculty Load Summary</h5>
                    <div class="col-md-4">
                        <div class="input-group">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search faculty or department..." />
                            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-secondary" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <asp:UpdatePanel ID="updFacultySummary" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="table-responsive">
                           <asp:GridView ID="gvFacultySummary" runat="server"
    CssClass="table table-hover"
    AutoGenerateColumns="False"
    DataKeyNames="FacultyID"
    OnRowCommand="gvFacultySummary_RowCommand"
    EmptyDataText="No faculty load assignments found.">

    <Columns>
        <asp:BoundField DataField="FacultyID" HeaderText="ID" ReadOnly="True" Visible="false" />

        <asp:TemplateField HeaderText="Faculty Name">
            <ItemTemplate>
                <div class="d-flex align-items-center">
                    <div class="flex-grow-1">
                        <div class="fw-semibold text-dark"><%# Eval("FacultyName") %></div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:BoundField DataField="DepartmentName" HeaderText="Department" />

       <asp:TemplateField HeaderText="Subjects Assigned">
    <ItemTemplate>
        <div class="text-center">
            <span class="badge subject-count-badge bg-primary rounded-pill">
                <%# GetSubjectCountDisplay(Eval("SubjectCount")) %>
            </span>
        </div>
    </ItemTemplate>
</asp:TemplateField>

        <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
                <div class="action-buttons">
                    <asp:LinkButton ID="btnViewDetails" runat="server" 
                        CommandName="ViewDetails" 
                        CommandArgument='<%# Eval("FacultyID") %>'
                        CssClass="btn btn-sm btn-outline-primary">
                        <i class="bi bi-eye me-1"></i> View Subjects
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnAssignSubject" runat="server" 
                        CommandName="AssignSubject" 
                        CommandArgument='<%# Eval("FacultyID") %>'
                        CssClass="btn btn-sm btn-success">
                        <i class="bi bi-plus-circle me-1"></i> Assign Subject
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>
</asp:GridView>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="gvFacultyDetails" EventName="RowDeleting" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
         
            <!-- Hidden Fields -->
            <asp:HiddenField ID="hfSelectedFacultyID" runat="server" />
        </div>
        
        <!-- Floating Action Button for Mobile -->
        <button type="button" class="btn btn-primary floating-action-btn d-md-none" data-bs-toggle="modal" data-bs-target="#assignFacultyModal">
            <i class="bi bi-person-plus"></i>
        </button>
    </form>

 <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Simple modal functions using jQuery
    function showAssignModal() {
        // Hide any other open modals first
        $('.modal').modal('hide');
        $('#assignFacultyModal').modal('show');
    }

    function hideAssignModal() {
        $('#assignFacultyModal').modal('hide');
    }

    function showDetailsModal() {
        $('.modal').modal('hide');
        $('#facultyDetailsModal').modal('show');
    }

    function showEditModal() {
        console.log('showEditModal function called');
        try {
            // Hide any other open modals first
            $('.modal').modal('hide');

            // Use a small delay to ensure other modals are hidden
            setTimeout(function () {
                var editModal = new bootstrap.Modal(document.getElementById('editFacultyLoadModal'));
                editModal.show();
                console.log('Edit modal should be visible now');
            }, 100);
        } catch (e) {
            console.error('Error showing edit modal:', e);
        }
    }
    function closeEditModal() {
        $('#editFacultyLoadModal').modal('hide');
    }

    // Add modal event listeners for debugging
    $(document).ready(function () {
        $('#editFacultyLoadModal').on('show.bs.modal', function () {
            console.log('Edit modal is being shown');
        });

        $('#editFacultyLoadModal').on('shown.bs.modal', function () {
            console.log('Edit modal is now fully visible');
        });

        $('#editFacultyLoadModal').on('hide.bs.modal', function () {
            console.log('Edit modal is being hidden');
        });
    });

    // Update the modal show event to reset form if needed
    $('#editFacultyLoadModal').on('show.bs.modal', function () {
        console.log('Edit modal is being shown');
    });

    $('#editFacultyLoadModal').on('shown.bs.modal', function () {
        console.log('Edit modal is now fully shown');
    });

    // Initialize when page loads
    $(document).ready(function () {
        console.log('Page loaded - modals initialized');

        // Initialize autocomplete
        initializeAutocomplete();

        // Initialize section field state
        updateSectionFieldState();
    });

    // Initialize autocomplete
    function initializeAutocomplete() {
        // Faculty autocomplete
        $('#<%= txtFaculty.ClientID %>').autocomplete({
        source: function (request, response) {
            $.ajax({
                type: "POST",
                url: "FacultyLoad.aspx/SearchFaculty",
                data: JSON.stringify({ searchTerm: request.term }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    const items = $.map(data.d, function (item) {
                        return { label: item.label, value: item.value, id: item.id };
                    });
                    response(items);
                }
            });
        },
        minLength: 2,
        select: function (event, ui) {
            $('#<%= hfFacultyID.ClientID %>').val(ui.item.id);
            $(this).val(ui.item.label);
            return false;
        }
    });

    // Subject autocomplete
    $('#<%= txtSubject.ClientID %>').autocomplete({
        source: function (request, response) {
            $.ajax({
                type: "POST",
                url: "FacultyLoad.aspx/SearchSubjects",
                data: JSON.stringify({ searchTerm: request.term }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    const items = $.map(data.d, function (item) {
                        return { label: item.label, value: item.value, id: item.id };
                    });
                    response(items);
                }
            });
        },
        minLength: 2,
        select: function (event, ui) {
            $('#<%= hfSubjectID.ClientID %>').val(ui.item.id);
            $(this).val(ui.item.label);
            return false;
        }
    });

    // Section autocomplete
    $('#<%= txtSection.ClientID %>').autocomplete({
        source: function (request, response) {
            const yearLevel = $('#<%= ddlYearLevel.ClientID %>').val();
            const courseID = $('#<%= ddlCourses.ClientID %>').val();

            if (!yearLevel || !courseID) {
                response([]);
                return;
            }

            $.ajax({
                type: "POST",
                url: "FacultyLoad.aspx/SearchSections",
                data: JSON.stringify({ searchTerm: request.term, yearLevel: yearLevel, courseID: courseID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    const items = $.map(data.d, function (item) {
                        return { label: item.label, value: item.value, id: item.id };
                    });
                    response(items);
                }
            });
        },
        minLength: 1,
        select: function (event, ui) {
            $('#<%= hfSectionValue.ClientID %>').val(ui.item.id);
            $(this).val(ui.item.label);
            return false;
        }
    });
}

// Update section field state
function updateSectionFieldState() {
    const yearVal = $('#<%= ddlYearLevel.ClientID %>').val();
    const courseVal = $('#<%= ddlCourses.ClientID %>').val();
    const sectionInput = $('#<%= txtSection.ClientID %>');

    if (yearVal && courseVal) {
        sectionInput.prop('disabled', false);
        sectionInput.attr('placeholder', 'Type section name...');
    } else {
        sectionInput.prop('disabled', true);
        sectionInput.val('');
            $('#<%= hfSectionValue.ClientID %>').val('');
            sectionInput.attr('placeholder', 'Select year level and course first');
        }
    }
    // Global variable to track if edit modal should stay open
    var keepEditModalOpen = false;

    function setKeepEditModalOpen(shouldKeepOpen) {
        keepEditModalOpen = shouldKeepOpen;
    }

    // Prevent edit modal from closing when there are validation errors
    $('#editFacultyLoadModal').on('hide.bs.modal', function (e) {
        if (keepEditModalOpen) {
            e.preventDefault();
            keepEditModalOpen = false; // Reset for next time
        }
    });

    function closeEditModal() {
        keepEditModalOpen = false;
        $('#editFacultyLoadModal').modal('hide');
    }
    // Global functions
    window.showAssignModal = showAssignModal;
    window.hideAssignModal = hideAssignModal;
    window.showDetailsModal = showDetailsModal;
    window.showEditModal = showEditModal;
</script>
</body>
</html>

