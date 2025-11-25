<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Students.aspx.vb" Inherits="Faculty_Evaluation_System.Students" EnableViewState="true"  %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Students - Faculty Evaluation System</title>
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
    
 
    .status-active { background-color: #28a745; }
    .status-inactive { background-color: #dc3545; }
    
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
        
        /* Card header adjustments */
        .card-header {
            flex-direction: column;
            align-items: flex-start !important;
        }
        
        .card-header .input-group {
            margin-top: 0.5rem;
            width: 100% !important;
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
    
    /* Collapsible card styling */
    .card-header.collapsible {
        cursor: pointer;
        display: flex;
        justify-content: space-between;
        align-items: center;
        transition: background-color 0.3s ease;
    }
    
    .card-header.collapsible:hover {
        background-color: #e9ecef;
    }
    
    /* Form section styling */
    .form-section {
        background-color: #f8f9fc;
        border-radius: 0.35rem;
        padding: 1.5rem;
        margin-bottom: 1rem;
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
    
    .form-actions {
        display: flex;
        justify-content: flex-end;
        margin-top: 1.5rem;
        padding-top: 1rem;
        border-top: 1px solid #e3e6f0;
    }
    
    /* Floating action button for mobile */
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
    }
    
    /* Animation for the add student card */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .fade-in {
        animation: fadeIn 0.3s ease forwards;
    }
    
    /* Required field indicator */
    .required-field::after {
        content: " *";
        color: #dc3545;
    }

    .autocomplete-suggestions {
        border: 1px solid #ddd;
        border-radius: 0.375rem;
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        background: white;
        max-height: 200px;
        overflow-y: auto;
        z-index: 1000;
    }

    .autocomplete-suggestions li {
        padding: 0.5rem 1rem;
        cursor: pointer;
        border: none;
        list-style: none;
    }

    .autocomplete-suggestions li:hover {
        background-color: #f8f9fa;
        color: var(--primary);
    }
    
    /* Add this to your CSS section */
    .update-progress {
        display: none !important;
    }

    /* Smooth transitions for the card */
    .card {
        transition: all 0.3s ease;
    }

    /* Prevent sudden jumps */
    .form-section {
        transition: all 0.3s ease;
    }

    /* Modal backdrop fix for autopostback */
    .modal-backdrop {
        z-index: 1040;
    }

    .modal {
        z-index: 1050;
    }

    /* Ensure modal stays on top during autopostback */
    .modal-open .modal {
        overflow-x: hidden;
        overflow-y: auto;
    }

    /* Keep modal open during postback */
    .modal-dialog {
        z-index: 1060;
    }
    
    /* Logo styling */
    .header-logo {
        height: 40px;
        width: auto;
        object-fit: contain;
        max-width: 150px;
    }
    
    /* Fallback placeholder styling if image doesn't load */
    .header-logo:not([src]), 
    .header-logo[src=""],
    .header-logo[src*="undefined"] {
        display: none;
    }
    
    /* Show placeholder when no logo is present */
    .d-flex.align-items-center.me-3:has(.header-logo:not(:visible))::before {
        content: "";
        display: inline-block;
        width: 40px;
        height: 40px;
        background: rgba(255, 255, 255, 0.2);
        border: 1px dashed rgba(255, 255, 255, 0.5);
        border-radius: 4px;
        margin-right: 0.5rem;
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
        
        /* Modal adjustments */
        .modal-dialog {
            margin: 0.5rem;
        }
        
        .modal-content {
            border-radius: 0.5rem;
        }
        
        /* Form adjustments */
        .form-section {
            padding: 1rem;
        }
        
        /* Table row adjustments */
        .table-responsive {
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
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
    
    /* GridView action buttons */
    .action-buttons {
        display: flex;
        flex-wrap: wrap;
        gap: 0.25rem;
    }
    
    @media (max-width: 768px) {
        .action-buttons {
            flex-direction: column;
        }
        
        .action-buttons .btn {
            margin-bottom: 0.25rem;
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
    
    /* Modal header with Golden West colors */
    .modal-header.bg-primary {
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%) !important;
        border-bottom: 2px solid var(--gold);
    }
    
    /* Card header with Golden West styling */
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

 /* Status badge styling - Match Students.aspx exactly */
.badge {
    font-size: 0.75rem;
    font-weight: 600;
    padding: 0.35rem 0.65rem;
}

.bg-success {
    background-color: var(--success) !important;
}

.bg-secondary {
    background-color: var(--secondary) !important;
}

.bg-warning {
    background-color: var(--warning) !important;
    color: #333 !important;
}
/* CSV Import Styles */
.import-instructions ul {
    padding-left: 1.5rem;
    margin-bottom: 0;
}

.import-instructions li {
    margin-bottom: 0.25rem;
}

/* File upload styling */
.form-control[type="file"] {
    padding: 0.5rem;
}

/* Template download button */
.btn-outline-primary {
    border-color: var(--primary);
    color: var(--primary);
}

.btn-outline-primary:hover {
    background-color: var(--primary);
    color: white;
}

/* Import results styling */
.alert ul {
    margin-bottom: 0;
}
.spinner {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

.btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}
/* Hide number input arrows */
input[type="number"]::-webkit-outer-spin-button,
input[type="number"]::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

input[type="number"] {
    -moz-appearance: textfield;
}
.bg-primary { background-color: var(--primary) !important; }
.bg-warning { background-color: var(--warning) !important; color: #333 !important; }

/* Student Type badge styling */
.badge {
    font-size: 0.75rem;
    font-weight: 600;
    padding: 0.35rem 0.65rem;
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
/* Modal form styling */
.form-control:disabled {
    background-color: #f8f9fa;
    color: #6c757d;
    cursor: not-allowed;
}

.form-control.bg-light {
    background-color: #f8f9fa !important;
}

/* Modal backdrop fix */
.modal-backdrop {
    z-index: 1040;
}

.modal {
    z-index: 1050;
}

/* Prevent body scroll when modal is open */
body.modal-open {
    overflow: hidden;
    padding-right: 0 !important;
}

/* Button states */
.btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

/* Success message styling */
.alert-success {
    border-left: 4px solid #28a745;
}

.alert-danger {
    border-left: 4px solid #dc3545;
}

.alert-warning {
    border-left: 4px solid #ffc107;
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
                <!-- Notifications with Text -->
                
                
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
                <a href="Students.aspx" class="list-group-item list-group-item-action active">
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
                <a href="FacultyLoad.aspx" class="list-group-item list-group-item-action">
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
                                <!-- NEW RELEASE RESULTS PAGE -->
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
    <h2 class="mb-0 page-title"><i class="bi bi-person-badge me-2 gold-accent"></i>Manage Students</h2>
  <!-- In the page header section with other buttons -->
<div class="d-flex gap-2">
      <!-- Add Export CSV Button -->
   <button type="button" class="btn btn-info text-white" id="btnExport" runat="server" 
    onserverclick="btnExportCSV_Click" onclientclick="showExportLoading();">
    <i class="bi bi-download me-1"></i>EXPORT CSV
</button>
    <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#importCSVModal">
        <i class="bi bi-upload me-1"></i>IMPORT CSV
    </button>
  
    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addStudentModal">
        <i class="bi bi-plus-circle me-1"></i>ADD STUDENT
    </button>
</div>
</div>

          <!-- Add Student Modal -->
<div class="modal fade" id="addStudentModal" tabindex="-1" aria-labelledby="addStudentModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="addStudentModalLabel">
                    <i class="bi bi-plus-circle me-2"></i>Add Student
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <asp:UpdatePanel ID="updAddStudent" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                    <ContentTemplate>
                        <!-- Modal-specific message area -->
                        <asp:Label ID="lblModalMessage" runat="server" CssClass="alert d-none mb-3" />
                        
                        <!-- Personal Information -->
                        <div class="form-section">
                            <div class="form-section-title">Personal Information</div>
                            <div class="row g-3 form-row-spaced">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold required-field">Last Name</label>
                                    <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" placeholder="Enter last name" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold required-field">First Name</label>
                                    <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control" placeholder="Enter first name" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Middle Initial</label>
                                    <asp:TextBox ID="txtMiddleInitial" runat="server" CssClass="form-control" placeholder="MI" MaxLength="1" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Suffix</label>
                                    <asp:TextBox ID="txtSuffix" runat="server" CssClass="form-control" placeholder="Jr, Sr, III" />
                                </div>
                               <div class="col-md-6">
    <label class="form-label fw-semibold required-field">School ID</label>
    <asp:TextBox ID="txtSchoolID" runat="server" CssClass="form-control" 
        placeholder="Enter school ID" MaxLength="10" 
        onkeypress="return allowOnlyNumbers(event)" />
</div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold required-field">Email Address</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" 
                                        placeholder="Enter email address" TextMode="Email" />
                                </div>
                            </div>
                        </div>
                        
                   
                        
                        <!-- Academic Information -->
                        <div class="form-section">
                            <div class="form-section-title">Academic Information</div>
                            <div class="row g-3 form-row-spaced">
                               
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Course</label>
                                   <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select"
    AutoPostBack="True" OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged">
    <asp:ListItem Value="">Select Course</asp:ListItem>
</asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Year Level</label>
                                    <asp:DropDownList ID="ddlYearLevel" runat="server" CssClass="form-select"
                                        AutoPostBack="True" OnSelectedIndexChanged="ddlYearLevel_SelectedIndexChanged">
                                        <asp:ListItem Value="">Select Year Level</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Section</label>
                                    <asp:TextBox ID="txtSection" runat="server" CssClass="form-control" 
                                        placeholder="Start typing section..." AutoPostBack="false" />
                                    <asp:HiddenField ID="hdnSectionValue" runat="server" />
                                </div>
                            
<div class="col-md-4">
    <label class="form-label fw-semibold required-field">Student Type</label>
    <asp:DropDownList ID="ddlStudentType" runat="server" CssClass="form-select">
        <asp:ListItem Value="Regular" Selected="True">Regular</asp:ListItem>
        <asp:ListItem Value="Irregular">Irregular</asp:ListItem>
    </asp:DropDownList>
</div>
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
                        
                        <asp:AsyncPostBackTrigger ControlID="ddlCourse" EventName="SelectedIndexChanged" />
                        <asp:AsyncPostBackTrigger ControlID="ddlYearLevel" EventName="SelectedIndexChanged" />
                        <asp:PostBackTrigger ControlID="btnAddStudent" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnAddStudent" runat="server" Text="Add Student" CssClass="btn btn-primary px-4" OnClick="btnAddStudent_Click" />
                <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>

<!-- Import CSV Modal -->
<div class="modal fade" id="importCSVModal" tabindex="-1" aria-labelledby="importCSVModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="importCSVModalLabel">
                    <i class="bi bi-upload me-2"></i>Import Students from CSV
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <!-- Remove the UpdatePanel and use direct postback for file upload -->
            <div class="modal-body">
                <!-- Import Instructions -->
                <div class="alert alert-info import-instructions">
                    <h6><i class="bi bi-info-circle me-2"></i>Import Instructions</h6>
                    <ul class="mb-0">
                        <li>Download the CSV template to ensure proper formatting</li>
                        <li><strong>Required columns:</strong> LastName, FirstName, SchoolID, Email, CourseName, YearLevel</li>
                        <li><strong>Optional columns:</strong> MiddleInitial, Suffix, Section (defaults to 'A')</li>
                        <li>Passwords will be automatically generated and emailed to students</li>
                        <li>Existing students with matching SchoolID or Email will be updated</li>
                    </ul>
                </div>

                <!-- Import Results Message -->
                <div id="importMessageContainer">
                    <asp:Label ID="lblImportMessage" runat="server" CssClass="alert d-none mb-3" />
                </div>

                <!-- File Upload -->
                <div class="mb-3">
                    <label class="form-label fw-semibold">Select CSV File</label>
                    <asp:FileUpload ID="fuCSV" runat="server" CssClass="form-control" accept=".csv" />
                    <div class="form-text">Maximum file size: 10MB</div>
                </div>

                <!-- Template Download -->
                <div class="d-flex justify-content-between align-items-center">
                    <asp:Button ID="btnDownloadTemplate" runat="server" Text="Download CSV Template" 
                        CssClass="btn btn-outline-primary" OnClick="btnDownloadTemplate_Click" />
                    
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnImportCSV" runat="server" Text="Import Students" 
                            CssClass="btn btn-primary" OnClick="btnImportCSV_Click" 
                            OnClientClick="return validateFileUpload();" />
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
          <!-- Add this Edit Student Modal after the Add Student Modal -->
<div class="modal fade" id="editStudentModal" tabindex="-1" aria-labelledby="editStudentModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="editStudentModalLabel">
                    <i class="bi bi-pencil-square me-2"></i>Edit Student
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <asp:UpdatePanel ID="updEditStudent" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                    <ContentTemplate>
                        <!-- Modal-specific message area -->
                        <asp:Label ID="lblEditMessage" runat="server" CssClass="alert d-none mb-3" />
                        
                        <!-- Hidden field for StudentID -->
                        <asp:HiddenField ID="hfEditStudentID" runat="server" />
                        
                        <!-- Personal Information -->
                        <div class="form-section">
                            <div class="form-section-title">Personal Information</div>
                            <div class="row g-3 form-row-spaced">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold required-field">Last Name</label>
                                    <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" placeholder="Enter last name" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold required-field">First Name</label>
                                    <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" placeholder="Enter first name" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Middle Initial</label>
                                    <asp:TextBox ID="txtEditMiddleInitial" runat="server" CssClass="form-control" placeholder="MI" MaxLength="1" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Suffix</label>
                                    <asp:TextBox ID="txtEditSuffix" runat="server" CssClass="form-control" placeholder="Jr, Sr, III" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold required-field">School ID</label>
                                    <asp:TextBox ID="txtEditSchoolID" runat="server" CssClass="form-control" 
                                        placeholder="Enter school ID" MaxLength="10" 
                                        onkeypress="return allowOnlyNumbers(event)" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold required-field">Email Address</label>
                                    <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" 
                                        placeholder="Enter email address" TextMode="Email" />
                                </div>
                            </div>
                        </div>
                        
                        <!-- Academic Information -->
                        <div class="form-section">
                            <div class="form-section-title">Academic Information</div>
                            <div class="row g-3 form-row-spaced">
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Course</label>
                                    <asp:DropDownList ID="ddlEditCourse" runat="server" CssClass="form-select"
                                        AutoPostBack="True" OnSelectedIndexChanged="ddlEditCourse_SelectedIndexChanged">
                                        <asp:ListItem Value="">Select Course</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Year Level</label>
                                    <asp:DropDownList ID="ddlEditYearLevel" runat="server" CssClass="form-select"
                                        AutoPostBack="True" OnSelectedIndexChanged="ddlEditYearLevel_SelectedIndexChanged">
                                        <asp:ListItem Value="">Select Year Level</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Section</label>
                                    <asp:TextBox ID="txtEditSection" runat="server" CssClass="form-control" 
                                        placeholder="Start typing section..." AutoPostBack="false" />
                                    <asp:HiddenField ID="hdnEditSectionValue" runat="server" />
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Student Type</label>
                                    <asp:DropDownList ID="ddlEditStudentType" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="Regular">Regular</asp:ListItem>
                                        <asp:ListItem Value="Irregular">Irregular</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold required-field">Status</label>
                                    <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="Active">Active</asp:ListItem>
                                        <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlEditCourse" EventName="SelectedIndexChanged" />
                        <asp:AsyncPostBackTrigger ControlID="ddlEditYearLevel" EventName="SelectedIndexChanged" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnUpdateStudent" runat="server" Text="Update Student" CssClass="btn btn-primary px-4" OnClick="btnUpdateStudent_Click" />
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>

<!-- Update the Students GridView to remove inline editing -->
<div class="card">
    <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h5 class="m-0 fw-bold text-primary"><i class="bi bi-list-ul me-2"></i>Students List</h5>
        <div class="col-md-4">
            <div class="input-group">
                <asp:TextBox ID="txtGridSearch" runat="server" CssClass="form-control" placeholder="Search students..." />
                <asp:Button ID="btnGridSearch" runat="server" Text="Search" CssClass="btn btn-secondary" OnClick="btnSearch_Click" />
            </div>
        </div>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <asp:GridView ID="gvStudents" runat="server"
                CssClass="table table-striped table-bordered table-hover"
                AutoGenerateColumns="False"
                AllowPaging="True" PageSize="50"
                DataKeyNames="StudentID"
                OnPageIndexChanging="gvStudents_PageIndexChanging"
                OnRowDataBound="gvStudents_RowDataBound"
                EnableViewState="True">
                <Columns>
                    <asp:TemplateField HeaderText="Last Name">
                        <ItemTemplate><%# Eval("LastName") %></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="First Name">
                        <ItemTemplate><%# Eval("FirstName") %></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="MI">
                        <ItemTemplate><%# Eval("MiddleInitial") %></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Suffix">
                        <ItemTemplate><%# Eval("Suffix") %></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="School ID">
                        <ItemTemplate><%# Eval("SchoolID") %></ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Email">
                        <ItemTemplate><%# Eval("Email") %></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Course">
                        <ItemTemplate><%# Eval("CourseName") %></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Year Level">
                        <ItemTemplate><%# Eval("YearLevel") %></ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Section">
                        <ItemTemplate><%# Eval("Section") %></ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Student Type">
                        <ItemTemplate>
                            <span class='badge <%# GetStudentTypeBadgeClass(Eval("StudentType").ToString()) %>'>
                                <i class='bi <%# GetStudentTypeIcon(Eval("StudentType").ToString()) %> me-1'></i>
                                <%# Eval("StudentType") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
                                <i class='bi <%# GetStatusIcon(Eval("Status").ToString()) %> me-1'></i>
                                <%# Eval("Status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="action-buttons">
                                <button type="button" class="btn btn-sm btn-gold me-1" 
                                    onclick='openEditModal(<%# Eval("StudentID") %>, "<%# Eval("LastName") %>", "<%# Eval("FirstName") %>", "<%# Eval("MiddleInitial") %>", "<%# Eval("Suffix") %>", "<%# Eval("SchoolID") %>", "<%# Eval("Email") %>", "<%# Eval("CourseID") %>", "<%# Eval("YearLevel") %>", "<%# Eval("Section") %>", "<%# Eval("StudentType") %>", "<%# Eval("Status") %>")'>
                                    <i class="bi bi-pencil"></i> Edit
                                </button>
                                <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-danger"
                                    OnClientClick="return confirm('WARNING: This will PERMANENTLY delete this student record. This action cannot be undone. Are you sure?');">
                                    <i class="bi bi-trash"></i> Delete
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="pagination" />
                <PagerSettings Mode="NumericFirstLast" />
            </asp:GridView>
        </div>
        <div class="d-flex justify-content-between align-items-center mt-3">
            <a href="StudentsBulk.aspx" class="forgot-link">Manage All Students</a>
        </div>
    </div>
</div>
        </div>
        
        <!-- Floating Action Button for Mobile -->
        <button type="button" class="btn btn-primary floating-action-btn d-md-none" data-bs-toggle="modal" data-bs-target="#addStudentModal">
            <i class="bi bi-plus-circle"></i>
        </button>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ========== STUDENT MANAGER - COMPLETE REWRITE ==========
    const StudentManager = {
        // Modal state management
        modalState: {
        addModal: null,
    editModal: null,
    importModal: null,
    currentModal: null,
    keepOpen: false,
    userClosed: false
        },

    // Initialize everything
    init: function() {
        this.initializeModals();
    this.initializeEventListeners();
    this.initializeAutocomplete();
    this.initializeSidebar();

    console.log('Student Manager initialized');
        },

    // ========== MODAL MANAGEMENT ==========
    initializeModals: function() {
        // Initialize Bootstrap modals
        this.modalState.addModal = new bootstrap.Modal(document.getElementById('addStudentModal'));
    this.modalState.editModal = new bootstrap.Modal(document.getElementById('editStudentModal'));
    this.modalState.importModal = new bootstrap.Modal(document.getElementById('importCSVModal'));

    // Add Student Modal event handlers
    const addModalEl = document.getElementById('addStudentModal');
    if (addModalEl) {
        addModalEl.addEventListener('show.bs.modal', () => {
            console.log('Add modal opening - resetting state');
            this.modalState.keepOpen = false;
            this.modalState.userClosed = false;
            this.modalState.currentModal = this.modalState.addModal;
        });

                addModalEl.addEventListener('hide.bs.modal', (e) => {
        console.log('Add modal hiding - keepOpen:', this.modalState.keepOpen, 'userClosed:', this.modalState.userClosed);

    // Prevent hiding if we need to keep it open (unless user manually closed)
    if (this.modalState.keepOpen && !this.modalState.userClosed) {
        console.log('Preventing modal close');
    e.preventDefault();
    return false;
                    }

    // Only reset form if modal is actually closing
    if (!this.modalState.keepOpen) {
        this.resetAddStudentForm();
                    }
                });

    // Setup close button handlers
    this.setupModalCloseHandlers(addModalEl);
            }

    // Edit Student Modal event handlers
    const editModalEl = document.getElementById('editStudentModal');
    if (editModalEl) {
        editModalEl.addEventListener('show.bs.modal', () => {
            this.modalState.currentModal = this.modalState.editModal;
        });

    this.setupModalCloseHandlers(editModalEl);
            }
        },

    setupModalCloseHandlers: function(modalElement) {
            const closeButtons = modalElement.querySelectorAll('[data-bs-dismiss="modal"], .btn-close, .btn-secondary, .btn-danger');
            
            closeButtons.forEach(button => {
        button.addEventListener('click', () => {
            console.log('Modal close triggered by user');
            this.modalState.userClosed = true;
            this.modalState.keepOpen = false;
        });
            });

            // Backdrop click handler
            modalElement.addEventListener('click', (e) => {
                if (e.target === modalElement) {
        console.log('Modal backdrop clicked');
    this.modalState.userClosed = true;
    this.modalState.keepOpen = false;
                }
            });
        },

    // Set whether modal should stay open after postback
    setKeepModalOpen: function(shouldKeepOpen) {
        console.log('setKeepModalOpen called:', shouldKeepOpen);
    this.modalState.keepOpen = shouldKeepOpen;

    // Reset userClosed flag when we want to keep open
    if (shouldKeepOpen) {
        this.modalState.userClosed = false;
            }
        },

    // Close modal programmatically
    closeModal: function() {
        console.log('Closing modal programmatically');
    this.modalState.keepOpen = false;
    this.modalState.userClosed = false;

    if (this.modalState.currentModal) {
        this.modalState.currentModal.hide();
            }
        },

    // Force close modal (bypass all checks)
    forceCloseModal: function() {
        console.log('Force closing modal');
    this.modalState.keepOpen = false;
    this.modalState.userClosed = true;

    if (this.modalState.currentModal) {
        this.modalState.currentModal.hide();
            }
        },

    // Check if modal should stay open based on validation messages
    shouldKeepModalOpen: function() {
            const modalMessage = document.getElementById('<%= lblModalMessage.ClientID %>');
    if (!modalMessage) return false;

    const messageText = modalMessage.textContent.trim();
    const isError = messageText.includes('⚠') ||
    messageText.includes('Please fill in all required fields') ||
    messageText.includes('already registered') ||
    messageText.includes('valid email') ||
    messageText.includes('No class found') ||
    messageText.includes('Unable to determine');

    console.log('Validation check - Message:', messageText, 'Is error:', isError);

    // Keep open only for errors AND if user hasn't manually closed
    return isError && !this.modalState.userClosed;
        },

    // ========== EVENT LISTENERS ==========
    initializeEventListeners: function() {
        // Window resize
        window.addEventListener('resize', () => this.handleResize());

            // Global click for autocomplete
            document.addEventListener('click', (e) => this.handleGlobalClick(e));

    // Course and Year Level change handlers
    this.setupDropdownEventListeners();
        },

    setupDropdownEventListeners: function() {
            // Main form dropdowns
            const ddlCourse = document.getElementById('<%= ddlCourse.ClientID %>');
            const ddlYearLevel = document.getElementById('<%= ddlYearLevel.ClientID %>');

    if (ddlCourse) {
        ddlCourse.addEventListener('change', () => {
            console.log('Course changed - keeping modal open');
            this.setKeepModalOpen(true);
            this.handleCourseChange();
        });
            }

    if (ddlYearLevel) {
        ddlYearLevel.addEventListener('change', () => {
            console.log('Year level changed - keeping modal open');
            this.setKeepModalOpen(true);
            this.handleYearLevelChange();
        });
            }

    // Edit form dropdowns
            const ddlEditCourse = document.getElementById('<%= ddlEditCourse.ClientID %>');
            const ddlEditYearLevel = document.getElementById('<%= ddlEditYearLevel.ClientID %>');

    if (ddlEditCourse) {
        ddlEditCourse.addEventListener('change', () => this.handleEditCourseChange());
            }

    if (ddlEditYearLevel) {
        ddlEditYearLevel.addEventListener('change', () => this.handleEditYearLevelChange());
            }
        },

    // ========== DROPDOWN CHANGE HANDLERS ==========
    handleCourseChange: function() {
            const txtSection = document.getElementById('<%= txtSection.ClientID %>');
    if (txtSection) {
        txtSection.value = '';
    this.clearAutocompleteSuggestions(txtSection);
            }
    this.validateSectionField();
        },

    handleYearLevelChange: function() {
            const txtSection = document.getElementById('<%= txtSection.ClientID %>');
    if (txtSection) {
        txtSection.value = '';
    this.clearAutocompleteSuggestions(txtSection);
            }
    this.validateSectionField();
        },

    handleEditCourseChange: function() {
            const txtEditSection = document.getElementById('<%= txtEditSection.ClientID %>');
    if (txtEditSection) {
        txtEditSection.value = '';
    this.clearAutocompleteSuggestions(txtEditSection);
            }
    this.validateEditSectionField();
        },

    handleEditYearLevelChange: function() {
            const txtEditSection = document.getElementById('<%= txtEditSection.ClientID %>');
    if (txtEditSection) {
        txtEditSection.value = '';
    this.clearAutocompleteSuggestions(txtEditSection);
            }
    this.validateEditSectionField();
        },

    // ========== FORM VALIDATION ==========
    validateSectionField: function() {
            const txtSection = document.getElementById('<%= txtSection.ClientID %>');
            const ddlCourse = document.getElementById('<%= ddlCourse.ClientID %>');
            const ddlYearLevel = document.getElementById('<%= ddlYearLevel.ClientID %>');

    if (txtSection && ddlCourse && ddlYearLevel) {
                const courseSelected = ddlCourse.value && ddlCourse.value !== '';
    const yearLevelSelected = ddlYearLevel.value && ddlYearLevel.value !== '';

    if (courseSelected && yearLevelSelected) {
        txtSection.disabled = false;
    txtSection.placeholder = "Start typing section...";
    txtSection.classList.remove('bg-light');
                } else {
        txtSection.disabled = true;
    txtSection.value = '';
    txtSection.placeholder = "Select course and year level first";
    txtSection.classList.add('bg-light');
    this.clearAutocompleteSuggestions(txtSection);
                }
            }
        },

    validateEditSectionField: function() {
            const txtEditSection = document.getElementById('<%= txtEditSection.ClientID %>');
            const ddlEditCourse = document.getElementById('<%= ddlEditCourse.ClientID %>');
            const ddlEditYearLevel = document.getElementById('<%= ddlEditYearLevel.ClientID %>');

    if (txtEditSection && ddlEditCourse && ddlEditYearLevel) {
                const courseSelected = ddlEditCourse.value && ddlEditCourse.value !== '';
    const yearLevelSelected = ddlEditYearLevel.value && ddlEditYearLevel.value !== '';

    if (courseSelected && yearLevelSelected) {
        txtEditSection.disabled = false;
    txtEditSection.placeholder = "Start typing section...";
    txtEditSection.classList.remove('bg-light');
                } else {
        txtEditSection.disabled = true;
    txtEditSection.value = '';
    txtEditSection.placeholder = "Select course and year level first";
    txtEditSection.classList.add('bg-light');
    this.clearAutocompleteSuggestions(txtEditSection);
                }
            }
        },

    // ========== AUTOCOMPLETE SYSTEM ==========
    initializeAutocomplete: function() {
        this.initializeMainFormAutocomplete();
    this.initializeEditFormAutocomplete();
        },

    initializeMainFormAutocomplete: function() {
            const txtSection = document.getElementById('<%= txtSection.ClientID %>');
            const ddlCourse = document.getElementById('<%= ddlCourse.ClientID %>');
            const ddlYearLevel = document.getElementById('<%= ddlYearLevel.ClientID %>');

    if (txtSection && ddlCourse && ddlYearLevel) {
        this.setupAutocomplete(txtSection, ddlCourse, ddlYearLevel);
            }
        },

    initializeEditFormAutocomplete: function() {
            const txtEditSection = document.getElementById('<%= txtEditSection.ClientID %>');
            const ddlEditCourse = document.getElementById('<%= ddlEditCourse.ClientID %>');
            const ddlEditYearLevel = document.getElementById('<%= ddlEditYearLevel.ClientID %>');

    if (txtEditSection && ddlEditCourse && ddlEditYearLevel) {
        this.setupAutocomplete(txtEditSection, ddlEditCourse, ddlEditYearLevel);
            }
        },

    setupAutocomplete: function(textbox, courseDropdown, yearLevelDropdown) {
            if (!textbox) return;

    let timeoutId = null;
    let isSelecting = false;

    // Clear existing autocomplete
    this.clearAutocompleteSuggestions(textbox);

            textbox.addEventListener('input', () => {
                if (isSelecting) return;
    if (timeoutId) clearTimeout(timeoutId);

                timeoutId = setTimeout(() => {
                    const courseID = courseDropdown?.value || '';
    const yearLevel = yearLevelDropdown?.value || '';
    const searchText = textbox.value.trim();

    this.clearAutocompleteSuggestions(textbox);
    if (searchText.length < 1 || !courseID || !yearLevel) return;

    this.fetchAutocompleteSuggestions(textbox, courseID, yearLevel, searchText);
                }, 300);
            });

            textbox.addEventListener('blur', () => {
        setTimeout(() => this.clearAutocompleteSuggestions(textbox), 200);
            });

            // Reset when course/year level changes
            [courseDropdown, yearLevelDropdown].forEach(dropdown => {
                if (dropdown) {
        dropdown.addEventListener('change', () => {
            if (textbox) {
                textbox.value = '';
                this.clearAutocompleteSuggestions(textbox);
            }
        });
                }
            });
        },

    fetchAutocompleteSuggestions: function(textbox, courseID, yearLevel, searchText) {
        this.showLoadingIndicator(textbox);

    if (typeof PageMethods !== 'undefined') {
        PageMethods.GetSections(courseID, yearLevel, searchText,
            (sections) => {
                this.hideLoadingIndicator(textbox);
                if (sections && sections.length > 0) {
                    this.showAutocompleteSuggestions(textbox, sections);
                } else {
                    this.clearAutocompleteSuggestions(textbox);
                }
            },
            (error) => {
                this.hideLoadingIndicator(textbox);
                console.error('Autocomplete error:', error);
                this.clearAutocompleteSuggestions(textbox);
            }
        );
            }
        },

    showLoadingIndicator: function(textbox) {
        textbox.style.backgroundImage = 'url("data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nMTYnIGhlaWdodD0nMTYnIHZpZXdCb3g9JzAgMCAxNiAxNicgZmlsbD0nbm9uZScgeG1sbnM9J2h0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnJz48Y2lyY2xlIGN4PSc4JyBjeT0nOCcgcj0nNycgc3Ryb2tlPScjN2E4MmFkJyBzdHJva2Utb3BhY2l0eT0nMC4zJyBzdHJva2Utd2lkdGg9JzEuNSc+PC9jaXJjbGU+PHBhdGggZD0nTTggMTVBNyA3IDAgMSAxIDggMScgc3Ryb2tlPScjNGU3M2RmJyBzdHJva2Utd2lkdGg9JzEuNSc+PC9wYXRoPjwvc3ZnPg==")';
    textbox.style.backgroundRepeat = 'no-repeat';
    textbox.style.backgroundPosition = 'right 10px center';
    textbox.style.backgroundSize = '16px 16px';
        },

    hideLoadingIndicator: function(textbox) {
        textbox.style.backgroundImage = '';
        },

    showAutocompleteSuggestions: function(textbox, sections) {
        this.clearAutocompleteSuggestions(textbox);

    const container = document.createElement('div');
    container.className = 'autocomplete-suggestions';
    Object.assign(container.style, {
        position: 'absolute',
    width: `${textbox.offsetWidth}px`,
    background: 'white',
    border: '1px solid #ddd',
    borderRadius: '4px',
    boxShadow: '0 2px 10px rgba(0,0,0,0.1)',
    maxHeight: '200px',
    overflowY: 'auto',
    zIndex: '1060'
            });

    const rect = textbox.getBoundingClientRect();
    container.style.top = `${rect.bottom + window.scrollY}px`;
    container.style.left = `${rect.left + window.scrollX}px`;

            sections.forEach(section => {
                const item = document.createElement('div');
    item.textContent = section;
    Object.assign(item.style, {
        padding: '8px 12px',
    cursor: 'pointer',
    borderBottom: '1px solid #f0f0f0'
                });

    item.addEventListener('mouseenter', function() {
        this.style.backgroundColor = '#f8f9fa';
    this.style.color = '#1a3a8f';
                });

    item.addEventListener('mouseleave', function() {
        this.style.backgroundColor = '';
    this.style.color = '';
                });

                item.addEventListener('mousedown', (e) => {
        e.preventDefault();
    isSelecting = true;
                });

                item.addEventListener('click', (e) => {
        e.preventDefault();
    textbox.value = section;
    this.clearAutocompleteSuggestions(textbox);
    textbox.focus();
    textbox.dispatchEvent(new Event('change', {bubbles: true }));
                    setTimeout(() => {isSelecting = false; }, 100);
                });

    container.appendChild(item);
            });

    document.body.appendChild(container);
    textbox._autocompleteContainer = container;
        },

    clearAutocompleteSuggestions: function(textbox) {
            if (textbox && textbox._autocompleteContainer) {
        textbox._autocompleteContainer.remove();
    textbox._autocompleteContainer = null;
            }
        },

    handleGlobalClick: function(event) {
            // Close autocomplete if clicking outside
            const allTextboxes = [
                document.getElementById('<%= txtSection.ClientID %>'),
                document.getElementById('<%= txtEditSection.ClientID %>')
    ];
            
            const isClickOnAutocomplete = allTextboxes.some(tb =>
    tb && tb._autocompleteContainer && tb._autocompleteContainer.contains(event.target)
    );
            
            const isClickOnTextbox = allTextboxes.some(tb =>
    tb && (tb === event.target || tb.contains(event.target))
    );

    if (!isClickOnAutocomplete && !isClickOnTextbox) {
        allTextboxes.forEach(tb => this.clearAutocompleteSuggestions(tb));
            }
        },

    // ========== SIDEBAR MANAGEMENT ==========
    initializeSidebar: function() {
            const sidebar = document.getElementById('sidebar');
    if (!sidebar) return;

    // Load collapsed state
    const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
    if (isCollapsed) this.collapseSidebar();

    // Sidebar toggler
    const sidebarToggler = document.getElementById('sidebarToggler');
    if (sidebarToggler) {
        sidebarToggler.addEventListener('click', () => this.toggleSidebar());
            }

    // Mobile sidebar toggler
    const mobileSidebarToggler = document.getElementById('mobileSidebarToggler');
    if (mobileSidebarToggler) {
        mobileSidebarToggler.addEventListener('click', () => this.toggleMobileSidebar());
            }
        },

    collapseSidebar: function() {
            const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');
    const sidebarToggler = document.getElementById('sidebarToggler');

    if (sidebar) sidebar.classList.add('collapsed');
    if (mainContent) mainContent.classList.add('collapsed');
    if (sidebarToggler) sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
        },

    expandSidebar: function() {
            const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');
    const sidebarToggler = document.getElementById('sidebarToggler');

    if (sidebar) sidebar.classList.remove('collapsed');
    if (mainContent) mainContent.classList.remove('collapsed');
    if (sidebarToggler) sidebarToggler.innerHTML = '<i class="bi bi-arrow-left-circle"></i>';
        },

    toggleSidebar: function() {
            const sidebar = document.getElementById('sidebar');
    if (sidebar.classList.contains('collapsed')) {
        this.expandSidebar();
    localStorage.setItem('sidebarCollapsed', 'false');
            } else {
        this.collapseSidebar();
    localStorage.setItem('sidebarCollapsed', 'true');
            }
        },

    toggleMobileSidebar: function() {
            const sidebar = document.getElementById('sidebar');
    const sidebarOverlay = document.getElementById('sidebarOverlay');

    if (sidebar) sidebar.classList.toggle('mobile-show');
    if (sidebarOverlay) sidebarOverlay.classList.toggle('show');
        },

    // ========== EDIT MODAL FUNCTIONALITY ==========
    openEditModal: function(studentID, lastName, firstName, middleInitial, suffix, schoolID, email, courseID, yearLevel, section, studentType, status) {
        console.log('Opening edit modal for student:', studentID);

    // Set hidden field
            document.getElementById('<%= hfEditStudentID.ClientID %>').value = studentID;

            // Populate form fields
            document.getElementById('<%= txtEditLastName.ClientID %>').value = lastName || '';
            document.getElementById('<%= txtEditFirstName.ClientID %>').value = firstName || '';
            document.getElementById('<%= txtEditMiddleInitial.ClientID %>').value = middleInitial || '';
            document.getElementById('<%= txtEditSuffix.ClientID %>').value = suffix || '';
            document.getElementById('<%= txtEditSchoolID.ClientID %>').value = schoolID || '';
            document.getElementById('<%= txtEditEmail.ClientID %>').value = email || '';
            document.getElementById('<%= txtEditSection.ClientID %>').value = section || '';

            // Set dropdown values
            this.setDropdownValue('<%= ddlEditCourse.ClientID %>', courseID);
            this.setDropdownValue('<%= ddlEditYearLevel.ClientID %>', yearLevel);
            this.setDropdownValue('<%= ddlEditStudentType.ClientID %>', studentType);
            this.setDropdownValue('<%= ddlEditStatus.ClientID %>', status);

            // Show modal
            this.modalState.editModal.show();
            
            // Initialize autocomplete for edit modal
            setTimeout(() => {
                this.initializeEditFormAutocomplete();
                this.validateEditSectionField();
            }, 500);
        },

        setDropdownValue: function(dropdownId, value) {
            const dropdown = document.getElementById(dropdownId);
            if (dropdown && value) {
                for (let i = 0; i < dropdown.options.length; i++) {
                    if (dropdown.options[i].value === value.toString()) {
                        dropdown.selectedIndex = i;
                        break;
                    }
                }
            }
        },

        closeEditModal: function() {
            this.modalState.editModal.hide();
            this.resetEditStudentForm();
        },

        // ========== FORM RESET FUNCTIONS ==========
        resetAddStudentForm: function() {
            const modalMessage = document.getElementById('<%= lblModalMessage.ClientID %>');
            if (modalMessage) {
                modalMessage.textContent = '';
                modalMessage.className = 'alert d-none mb-3';
            }

            const fieldsToReset = [
                document.getElementById('<%= txtLastName.ClientID %>'),
                document.getElementById('<%= txtFirstName.ClientID %>'),
                document.getElementById('<%= txtMiddleInitial.ClientID %>'),
                document.getElementById('<%= txtSuffix.ClientID %>'),
                document.getElementById('<%= txtSchoolID.ClientID %>'),
                document.getElementById('<%= txtEmail.ClientID %>'),
                document.getElementById('<%= txtSection.ClientID %>')
            ];

            fieldsToReset.forEach(field => {
                if (field) {
                    field.value = '';
                    field.classList.remove('is-invalid', 'is-valid');
                }
            });

            // Reset dropdowns
            const ddlCourse = document.getElementById('<%= ddlCourse.ClientID %>');
            const ddlYearLevel = document.getElementById('<%= ddlYearLevel.ClientID %>');
            if (ddlCourse) ddlCourse.selectedIndex = 0;
            if (ddlYearLevel) ddlYearLevel.selectedIndex = 0;

            this.validateSectionField();
        },

        resetEditStudentForm: function() {
            const editMessage = document.getElementById('<%= lblEditMessage.ClientID %>');
            if (editMessage) {
                editMessage.textContent = '';
                editMessage.className = 'alert d-none mb-3';
            }
        },

        // ========== UTILITY FUNCTIONS ==========
        handleResize: function() {
            if (window.innerWidth >= 768) {
                const sidebar = document.getElementById('sidebar');
                const sidebarOverlay = document.getElementById('sidebarOverlay');
                
                if (sidebar) sidebar.classList.remove('mobile-show');
                if (sidebarOverlay) sidebarOverlay.classList.remove('show');
            }
        },

        allowOnlyNumbers: function(event) {
            const charCode = (event.which) ? event.which : event.keyCode;
            if (charCode > 31 && (charCode < 48 || charCode > 57)) {
                event.preventDefault();
                return false;
            }
            return true;
        },

        // ========== CSV IMPORT/EXPORT ==========
        validateFileUpload: function() {
            const fileUpload = document.getElementById('<%= fuCSV.ClientID %>');
            
            if (!fileUpload) {
                alert('❌ File upload control not found. Please refresh the page.');
                return false;
            }

            if (!fileUpload.value) {
                alert('⚠ Please select a CSV file to upload.');
                return false;
            }

            const fileExtension = fileUpload.value.toLowerCase().split('.').pop();
            if (fileExtension !== 'csv') {
                alert('⚠ Please upload a valid CSV file. Selected file: ' + fileUpload.value);
                return false;
            }

            const importBtn = document.getElementById('<%= btnImportCSV.ClientID %>');
    if (importBtn) {
        importBtn.disabled = true;
    importBtn.innerHTML = '<i class="bi bi-arrow-repeat spinner"></i> Importing...';
            }

    return true;
        },

    showExportLoading: function() {
            const exportBtn = document.getElementById('btnExport');
    if (exportBtn) {
        exportBtn.disabled = true;
    exportBtn.innerHTML = '<i class="bi bi-arrow-repeat spinner"></i> Exporting...';
            }
        }
    };

    // ========== INITIALIZATION ==========
    document.addEventListener('DOMContentLoaded', function() {
        StudentManager.init();
    });

    // ========== ASP.NET AJAX INTEGRATION ==========
    if (typeof Sys !== 'undefined') {
        const prm = Sys.WebForms.PageRequestManager.getInstance();

    prm.add_beginRequest(function(sender, args) {
        console.log('Async postback starting from:', args.get_postBackElement().id);
        });

    prm.add_endRequest(function(sender, args) {
        console.log('Async postback completed');

    // Reinitialize components
    StudentManager.initializeAutocomplete();
    StudentManager.validateSectionField();
    StudentManager.validateEditSectionField();

            // Check if we should keep modal open after postback
            setTimeout(() => {
                const shouldKeepOpen = StudentManager.shouldKeepModalOpen();
    console.log('Postback completed - should keep modal open:', shouldKeepOpen);

    if (shouldKeepOpen) {
        StudentManager.setKeepModalOpen(true);
                } else {
                    // Only close if not keeping open AND user hasn't manually closed
                    if (!StudentManager.modalState.keepOpen && !StudentManager.modalState.userClosed) {
        console.log('Closing modal after successful operation');
    StudentManager.closeModal();
                    }
                }
            }, 100);
        });
    }

    // ========== GLOBAL EXPORTS ==========
    window.setKeepModalOpen = function(keepOpen) {
        StudentManager.setKeepModalOpen(keepOpen); 
    };

    window.closeModal = function() {
        StudentManager.closeModal(); 
    };

    window.forceCloseModal = function() {
        StudentManager.forceCloseModal(); 
    };

    window.openEditModal = function(studentID, lastName, firstName, middleInitial, suffix, schoolID, email, courseID, yearLevel, section, studentType, status) {
        StudentManager.openEditModal(studentID, lastName, firstName, middleInitial, suffix, schoolID, email, courseID, yearLevel, section, studentType, status);
    };

    window.closeEditModal = function() {
        StudentManager.closeEditModal(); 
    };

    window.validateFileUpload = function() { 
        return StudentManager.validateFileUpload(); 
    };

    window.showExportLoading = function() {
        StudentManager.showExportLoading(); 
    };

    window.allowOnlyNumbers = function(event) { 
        return StudentManager.allowOnlyNumbers(event); 
    };

    // Debug function
    window.debugStudentManager = function() {
        console.log('=== StudentManager Debug Info ===');
    console.log('Modal State:', StudentManager.modalState);
    };
</script>

</body>
</html>

