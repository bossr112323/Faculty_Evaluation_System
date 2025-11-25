<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Users.aspx.vb" Inherits="Faculty_Evaluation_System.Users" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Users - Faculty Evaluation System</title>
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
        
        /* Card styling */
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
        
        /* Nav tabs with Golden West colors */
        .nav-tabs .nav-link {
            border: none;
            border-bottom: 3px solid transparent;
            color: var(--dark);
            font-weight: 500;
            padding: 0.75rem 1.25rem;
        }
        
        .nav-tabs .nav-link.active {
            border-bottom: 3px solid var(--gold);
            color: var(--primary);
            background: transparent;
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
            
            /* Tab navigation for mobile */
            .nav-tabs .nav-link {
                padding: 0.5rem 0.75rem;
                font-size: 0.875rem;
            }
            
            /* Search bar adjustments */
            .search-container {
                width: 100%;
                margin-top: 0.5rem;
            }
            
            .search-container .input-group {
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
        
        .card-header.collapsible .bi-chevron-down {
            transition: transform 0.3s ease;
        }
        
        .card-header.collapsible.collapsed .bi-chevron-down {
            transform: rotate(-90deg);
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
        
        /* Animation for the add user card */
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
        
        /* Modal styling */
        .modal {
            z-index: 1060;
        }
        
        .modal-backdrop {
            z-index: 1050;
        }
        
        /* Focus management for better accessibility */
        .modal .btn-close:focus {
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
            outline: 2px solid #0056b3;
        }
        
        /* Ensure modal content is properly hidden when not active */
        .modal:not(.show) {
            display: none !important;
        }
        
        /* Prevent body scroll when modal is open */
        body.modal-open {
            overflow: hidden;
            padding-right: 0px !important;
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
            
            /* Page title and button adjustments */
            .page-header {
                flex-direction: column;
                align-items: flex-start !important;
            }
            
            .page-header .btn {
                margin-top: 0.5rem;
                align-self: flex-end;
            }
            
            /* Tab container adjustments */
            .tabs-container {
                flex-direction: column;
            }
            
            .tabs-container .nav-tabs {
                order: 2;
                margin-top: 1rem;
            }
            
            .tabs-container .search-container {
                order: 1;
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
        
        /* Search bar styling */
        .search-container {
            min-width: 250px;
        }
        
        /* Table row hover effect */
        .table-hover tbody tr:hover {
            background-color: rgba(26, 58, 143, 0.05);
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
/* Hide number input arrows */
input[type="number"]::-webkit-outer-spin-button,
input[type="number"]::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}

input[type="number"] {
    -moz-appearance: textfield;
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
.department-field {
    transition: all 0.3s ease;
}

.form-section {
    transition: all 0.3s ease;
}
.department-field {
    transition: all 0.3s ease;
}

/* Ensure hidden elements don't take space */
.department-field[style*="display: none"] {
    display: none !important;
}
/* Import Modal Styling */
#importModal .modal-dialog {
    max-width: 500px;
}

#importModal .alert-info {
    border-left: 4px solid var(--info);
}

#importModal .form-text {
    font-size: 0.875rem;
    color: var(--secondary);
    margin-top: 0.25rem;
}

#importModal .bi-lightbulb {
    color: var(--warning);
}

#importModal .modal-footer {
    border-top: 1px solid #dee2e6;
    padding: 1rem 1.5rem;
}
/* Import Modal Styling */
#importModal .modal-dialog {
    max-width: 800px;
}

#importModal .import-instructions {
    border-left: 4px solid #17a2b8;
    background-color: #f8f9fa;
}

#importModal .import-instructions h6 {
    color: #0c5460;
    font-weight: 600;
}

#importModal .import-instructions ul {
    padding-left: 1.5rem;
}

#importModal .import-instructions li {
    margin-bottom: 0.25rem;
    color: #0c5460;
}

#importModal .form-text {
    font-size: 0.875rem;
    color: #6c757d;
    margin-top: 0.25rem;
}

#importModal .btn-outline-primary {
    border-color: var(--primary);
    color: var(--primary);
}

#importModal .btn-outline-primary:hover {
    background-color: var(--primary);
    color: white;
}

/* File upload styling */
#importModal .form-control:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
}
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
      <div class="header-bar">
    <div class="d-flex align-items-center">
        <button id="mobileSidebarToggler" class="btn btn-sm btn-outline-secondary me-2 d-lg-none" type="button">
            <i class="bi bi-list"></i>
        </button>
        <!-- Logo Section -->
        <div class="d-flex align-items-center me-3">
            <img src="Image/logo.png" alt="Company Logo" class="header-logo me-2" 
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
            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userMenu" 
                    data-bs-toggle="dropdown" aria-expanded="false">
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
                <a href="Users.aspx" class="list-group-item list-group-item-action active">
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
    
   <!-- Add these buttons in the page header section -->
<div class="d-flex justify-content-between align-items-center mb-4 page-header">
    <h2 class="mb-0 page-title"><i class="bi bi-people me-2 gold-accent"></i>Manage Users</h2>
    <div class="d-flex gap-2">
        <button type="button" class="btn btn-info text-white" id="btnExport" runat="server" onserverclick="btnExport_Click">
            <i class="bi bi-download me-1"></i>EXPORT CSV
        </button>
        <button type="button" class="btn btn-success text-white" data-bs-toggle="modal" data-bs-target="#importModal">
            <i class="bi bi-upload me-1"></i>IMPORT CSV
        </button>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal">
            <i class="bi bi-person-plus me-1"></i>ADD USER
        </button>
    </div>
</div>

    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true" data-bs-backdrop="static">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="addUserModalLabel">
                        <i class="bi bi-person-plus me-2"></i>Add New User
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <!-- Modal-specific message area -->
                    <asp:Label ID="lblModalMessage" runat="server" CssClass="alert d-none mb-3" />
                    
                    <div class="form-section">
                        <div class="form-section-title">Basic Information</div>
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
                                <asp:TextBox ID="txtMiddleInitial" runat="server" CssClass="form-control" placeholder="MI" MaxLength="5" />
                            </div>
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Suffix</label>
                                <asp:TextBox ID="txtSuffix" runat="server" CssClass="form-control" placeholder="Jr, Sr, III"  MaxLength="10" />
                            </div>
                         <div class="col-md-6">
    <label class="form-label fw-semibold required-field">School ID</label>
    <asp:TextBox ID="txtSchoolID" runat="server" CssClass="form-control" 
        placeholder="Enter school ID (numbers only)" 
        MaxLength="10"
        onkeypress="return isNumberKey(event)" 
        oninput="validateSchoolID(this)" />
    <div class="invalid-feedback" id="schoolIDError">Please enter numbers only (max 10 digits)</div>
</div>
                        </div>
                    </div>
                    
                  <div class="form-section">
    <div class="form-section-title">Account Details</div>
    <div class="row g-3 form-row-spaced">
        <div class="col-md-6">
            <label class="form-label fw-semibold">
                <span id="emailLabel">Email</span>
                <span id="emailRequired" class="required-field"> *</span>
            </label>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter email address" TextMode="Email" />
            <small class="form-text text-muted" id="emailHelp">Password will be auto-generated and sent via email</small>
        </div>
        <div class="col-md-4">
            <label class="form-label fw-semibold required-field">Role</label>
            <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select">
                <asp:ListItem Value="">Select Role</asp:ListItem>
                <asp:ListItem Value="Faculty">Faculty</asp:ListItem>
                <asp:ListItem Value="Dean">Dean</asp:ListItem>
                <asp:ListItem Value="Registrar">Registrar</asp:ListItem>
            </asp:DropDownList>
        </div>
  <div class="form-section department-field">
    <div class="form-section-title">Department Information</div>
    <div class="row g-3 form-row-spaced">
        <div class="col-md-6">
            <label class="form-label fw-semibold">
                <span id="departmentLabel">Department</span>
                <span id="departmentRequired" class="required-field"> *</span>
            </label>
            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select">
                <asp:ListItem Value="">Select Department</asp:ListItem>
            </asp:DropDownList>
            <small class="form-text text-muted" id="departmentHelp">Department is only required for Faculty and Dean roles</small>
        </div>
    </div>
</div>
    </div>
</div>
                    </div>
                <div class="modal-footer">
                    <asp:Button ID="btnAddUser" runat="server" Text="Add User" CssClass="btn btn-primary px-4" OnClick="btnAddUser_Click" />
                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>


    <!-- Add these hidden fields -->
<asp:HiddenField ID="hfEditUserID" runat="server" />

<!-- Edit User Modal -->
<div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="editUserModalLabel">
                    <i class="bi bi-person-gear me-2"></i>Edit User
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- Edit modal message area -->
                <asp:Label ID="lblEditMessage" runat="server" CssClass="alert d-none mb-3" />
                
                <div class="form-section">
                    <div class="form-section-title">Basic Information</div>
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
                            <asp:TextBox ID="txtEditMiddleInitial" runat="server" CssClass="form-control" placeholder="MI" MaxLength="5" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Suffix</label>
                            <asp:TextBox ID="txtEditSuffix" runat="server" CssClass="form-control" placeholder="Jr, Sr, III" MaxLength="10" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold required-field">School ID</label>
                            <asp:TextBox ID="txtEditSchoolID" runat="server" CssClass="form-control" 
                                placeholder="Enter school ID" 
                                MaxLength="10"
                                onkeypress="return isNumberKey(event)" 
                                oninput="validateSchoolID(this)" />
                        </div>
                    </div>
                </div>
                
                <div class="form-section">
                    <div class="form-section-title">Account Details</div>
                    <div class="row g-3 form-row-spaced">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold required-field">Email</label>
                            <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" placeholder="Enter email address" TextMode="Email" />
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold required-field">Role</label>
                            <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">Select Role</asp:ListItem>
                                <asp:ListItem Value="Faculty">Faculty</asp:ListItem>
                                <asp:ListItem Value="Dean">Dean</asp:ListItem>
                                <asp:ListItem Value="Registrar">Registrar</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-section department-field">
    <div class="form-section-title">Department Information</div>
    <div class="row g-3 form-row-spaced">
        <div class="col-md-12">
            <label class="form-label fw-semibold">
                <span id="editDepartmentLabel">Department</span>
                <span id="editDepartmentRequired" class="required-field"> *</span>
            </label>
            <asp:DropDownList ID="ddlEditDepartment" runat="server" CssClass="form-select">
                <asp:ListItem Value="">Select Department</asp:ListItem>
            </asp:DropDownList>
            <small class="form-text text-muted" id="editDepartmentHelp">Department is only required for Faculty and Dean roles</small>
        </div>
    </div>
</div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold required-field">Status</label>
                            <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select">
                                <asp:ListItem Value="Active">Active</asp:ListItem>
                                <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnUpdateUser" runat="server" Text="Update User" CssClass="btn btn-primary px-4" OnClick="btnUpdateUser_Click" />
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>
 <!-- Import Users Modal -->
<div class="modal fade" id="importModal" tabindex="-1" aria-labelledby="importModalLabel" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="importModalLabel">
                    <i class="bi bi-upload me-2"></i>Import Users from CSV
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <div class="modal-body">
                <!-- Import Instructions -->
                <div class="alert alert-info import-instructions">
                    <h6><i class="bi bi-info-circle me-2"></i>Import Instructions</h6>
                    <ul class="mb-0">
                        <li>Download the CSV template to ensure proper formatting</li>
                        <li><strong>Required columns:</strong> LastName, FirstName, SchoolID, Email, Role, DepartmentName</li>
                        <li><strong>Optional columns:</strong> MiddleInitial, Suffix</li>
                        <li>Passwords will be automatically generated and emailed to users</li>
                        <li>Existing users with matching SchoolID or Email will be updated</li>
                        <li><strong>Note:</strong> DepartmentName is required for Faculty and Dean roles only</li>
                    </ul>
                </div>

                <!-- Import Results Message -->
                <div id="importMessageContainer">
                    <asp:Label ID="lblImportMessage" runat="server" CssClass="alert d-none mb-3" />
                </div>

                <!-- File Upload -->
                <div class="mb-4">
                    <label class="form-label fw-semibold">Select CSV File</label>
                    <asp:FileUpload ID="fuImport" runat="server" CssClass="form-control" accept=".csv" />
                    <div class="form-text">Maximum file size: 10MB</div>
                </div>

                <!-- Template Download and Action Buttons -->
                <div class="d-flex justify-content-between align-items-center">
                    <asp:Button ID="btnDownloadTemplate" runat="server" Text="Download CSV Template" 
                        CssClass="btn btn-outline-primary" OnClientClick="downloadTemplate(); return false;" />
                    
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnImport" runat="server" Text="Import Users" 
                            CssClass="btn btn-primary" OnClick="btnImport_Click" 
                            OnClientClick="return validateFileUpload();" />
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>    <!-- Tabs and Search Container -->
    <div class="d-flex justify-content-between align-items-center mb-3 tabs-container">
        <ul class="nav nav-tabs" id="userTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="faculty-tab" data-bs-toggle="tab" data-bs-target="#faculty" type="button" role="tab">
                    <i class="bi bi-person-check me-1"></i>Faculty
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="dean-tab" data-bs-toggle="tab" data-bs-target="#dean" type="button" role="tab">
                    <i class="bi bi-award me-1"></i>Dean
                </button>
            </li>
             <li class="nav-item" role="presentation">
     <button class="nav-link" id="registrar-tab" data-bs-toggle="tab" data-bs-target="#registrar" type="button" role="tab">
         <i class="bi bi-clipboard-data me-1"></i>Registrar
     </button>
 </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="hr-tab" data-bs-toggle="tab" data-bs-target="#hr" type="button" role="tab">
                    <i class="bi bi-person-badge me-1"></i>Admin
                </button>
            </li>
           
        </ul>
        
        <!-- Search Bar -->
        <div class="col-md-4">
            <div class="input-group">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search users..." />
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-secondary" OnClick="btnSearch_Click" />
            </div>
        </div>
    </div>

    <div class="tab-content">
        <!-- Faculty -->
        <div class="tab-pane fade show active" id="faculty" role="tabpanel">
            <div class="table-responsive">
               <asp:GridView ID="gvFaculty" runat="server" CssClass="table table-striped table-bordered table-hover"
    AutoGenerateColumns="False" DataKeyNames="UserID,Role" AllowPaging="true" PageSize="25"
    OnPageIndexChanging="gv_PageIndexChanging" OnRowEditing="gv_RowEditing"
    OnRowCancelingEdit="gv_RowCancelingEdit" OnRowUpdating="gv_RowUpdating" 
    OnRowDeleting="gv_RowDeleting" OnRowDataBound="gv_RowDataBound">

                    <Columns>
                        <asp:TemplateField HeaderText="Last Name">
                            <ItemTemplate><%# Eval("LastName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" Text='<%# Bind("LastName") %>' placeholder="Last Name" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="First Name">
                            <ItemTemplate><%# Eval("FirstName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" Text='<%# Bind("FirstName") %>' placeholder="First Name" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="MI">
                            <ItemTemplate><%# Eval("MiddleInitial") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditMiddleInitial" runat="server" CssClass="form-control" Text='<%# Bind("MiddleInitial") %>' placeholder="MI" MaxLength="1" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Suffix">
                            <ItemTemplate><%# Eval("Suffix") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditSuffix" runat="server" CssClass="form-control" Text='<%# Bind("Suffix") %>' placeholder="Suffix" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                       <asp:TemplateField HeaderText="School ID">
    <ItemTemplate><%# Eval("SchoolID") %></ItemTemplate>
    <EditItemTemplate>
        <asp:TextBox ID="txtEditSchoolID" runat="server" CssClass="form-control" 
            Text='<%# Bind("SchoolID") %>' placeholder="School ID" 
            MaxLength="10"
            onkeypress="return isNumberKey(event)" 
            oninput="validateSchoolID(this)" />
    </EditItemTemplate>
</asp:TemplateField>

                        <asp:TemplateField HeaderText="Email">
                            <ItemTemplate><%# Eval("Email") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" Text='<%# Bind("Email") %>' TextMode="Email" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate><%# Eval("Role") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Faculty">Faculty</asp:ListItem>
                                    <asp:ListItem Value="Dean">Dean</asp:ListItem>
                                    <asp:ListItem Value="Registrar">Registrar</asp:ListItem>
                                </asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Department">
                            <ItemTemplate><%# Eval("DepartmentName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditDepartment" runat="server" CssClass="form-select"></asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>
<asp:TemplateField HeaderText="Status">
    <ItemTemplate>
        <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
            <i class='bi <%# GetStatusIcon(Eval("Status").ToString()) %> me-1'></i>
            <%# Eval("Status") %>
        </span>
    </ItemTemplate>
    <EditItemTemplate>
        <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select">
            <asp:ListItem Value="Active">Active</asp:ListItem>
            <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
        </asp:DropDownList>
    </EditItemTemplate>
</asp:TemplateField>

                       <asp:TemplateField HeaderText="Actions">
    <ItemTemplate>
        <button type="button" class="btn btn-sm btn-gold me-1" 
                onclick='openEditModal(<%# Eval("UserID") %>, "<%# Eval("LastName") %>", "<%# Eval("FirstName") %>", "<%# Eval("MiddleInitial") %>", "<%# Eval("Suffix") %>", "<%# Eval("SchoolID") %>", "<%# Eval("Email") %>", "<%# Eval("Role") %>", "<%# Eval("DepartmentID") %>", "<%# Eval("Status") %>")'>
            <i class="bi bi-pencil"></i> Edit
        </button>
        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-danger"
            OnClientClick="return confirm('Are you sure you want to delete this user?');">
            <i class="bi bi-trash"></i> Delete
        </asp:LinkButton>
    </ItemTemplate>
</asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination" />
                    <PagerSettings Mode="NumericFirstLast" />
                </asp:GridView>
            </div>
        </div>

        <!-- Dean -->
        <div class="tab-pane fade" id="dean" role="tabpanel">
            <div class="table-responsive">
                <asp:GridView ID="gvDean" runat="server" CssClass="table table-striped table-bordered table-hover"
    AutoGenerateColumns="False" DataKeyNames="UserID,Role" AllowPaging="true" PageSize="25"
    OnPageIndexChanging="gv_PageIndexChanging" OnRowEditing="gv_RowEditing"
    OnRowCancelingEdit="gv_RowCancelingEdit" OnRowUpdating="gv_RowUpdating" 
    OnRowDeleting="gv_RowDeleting" OnRowDataBound="gv_RowDataBound">
                    <Columns>
                        <asp:TemplateField HeaderText="Last Name">
                            <ItemTemplate><%# Eval("LastName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" Text='<%# Bind("LastName") %>' placeholder="Last Name" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="First Name">
                            <ItemTemplate><%# Eval("FirstName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" Text='<%# Bind("FirstName") %>' placeholder="First Name" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="MI">
                            <ItemTemplate><%# Eval("MiddleInitial") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditMiddleInitial" runat="server" CssClass="form-control" Text='<%# Bind("MiddleInitial") %>' placeholder="MI" MaxLength="1" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Suffix">
                            <ItemTemplate><%# Eval("Suffix") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditSuffix" runat="server" CssClass="form-control" Text='<%# Bind("Suffix") %>' placeholder="Suffix" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                     <asp:TemplateField HeaderText="School ID">
    <ItemTemplate><%# Eval("SchoolID") %></ItemTemplate>
    <EditItemTemplate>
        <asp:TextBox ID="txtEditSchoolID" runat="server" CssClass="form-control" 
            Text='<%# Bind("SchoolID") %>' placeholder="School ID" 
            MaxLength="20"
            onkeypress="return isNumberKey(event)" 
            oninput="validateSchoolID(this)" />
    </EditItemTemplate>
</asp:TemplateField>

                        <asp:TemplateField HeaderText="Email">
                            <ItemTemplate><%# Eval("Email") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" Text='<%# Bind("Email") %>' TextMode="Email" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate><%# Eval("Role") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Faculty">Faculty</asp:ListItem>
                                    <asp:ListItem Value="Dean">Dean</asp:ListItem>
                                    <asp:ListItem Value="Registrar">Registrar</asp:ListItem>
                                </asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Department">
                            <ItemTemplate><%# Eval("DepartmentName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditDepartment" runat="server" CssClass="form-select"></asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>
<asp:TemplateField HeaderText="Status">
    <ItemTemplate>
        <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
            <i class='bi <%# GetStatusIcon(Eval("Status").ToString()) %> me-1'></i>
            <%# Eval("Status") %>
        </span>
    </ItemTemplate>
    <EditItemTemplate>
        <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select">
            <asp:ListItem Value="Active">Active</asp:ListItem>
            <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
        </asp:DropDownList>
    </EditItemTemplate>
</asp:TemplateField>
                      <asp:TemplateField HeaderText="Actions">
    <ItemTemplate>
        <button type="button" class="btn btn-sm btn-gold me-1" 
                onclick='openEditModal(<%# Eval("UserID") %>, "<%# Eval("LastName") %>", "<%# Eval("FirstName") %>", "<%# Eval("MiddleInitial") %>", "<%# Eval("Suffix") %>", "<%# Eval("SchoolID") %>", "<%# Eval("Email") %>", "<%# Eval("Role") %>", "<%# Eval("DepartmentID") %>", "<%# Eval("Status") %>")'>
            <i class="bi bi-pencil"></i> Edit
        </button>
        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-danger"
            OnClientClick="return confirm('Are you sure you want to delete this user?');">
            <i class="bi bi-trash"></i> Delete
        </asp:LinkButton>
    </ItemTemplate>
</asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination" />
                    <PagerSettings Mode="NumericFirstLast" />
                </asp:GridView>
            </div>
        </div>
          <!-- Registrar -->
  <div class="tab-pane fade" id="registrar" role="tabpanel">
      <div class="table-responsive">
        <asp:GridView ID="gvRegistrar" runat="server" CssClass="table table-striped table-bordered table-hover"
    AutoGenerateColumns="False" DataKeyNames="UserID,Role" AllowPaging="true" PageSize="25"
    OnPageIndexChanging="gv_PageIndexChanging" OnRowEditing="gv_RowEditing"
    OnRowCancelingEdit="gv_RowCancelingEdit" OnRowUpdating="gv_RowUpdating" 
    OnRowDeleting="gv_RowDeleting" OnRowDataBound="gv_RowDataBound">
              <Columns>
                  <asp:TemplateField HeaderText="Last Name">
                      <ItemTemplate><%# Eval("LastName") %></ItemTemplate>
                      <EditItemTemplate>
                          <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" Text='<%# Bind("LastName") %>' placeholder="Last Name" />
                      </EditItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="First Name">
                      <ItemTemplate><%# Eval("FirstName") %></ItemTemplate>
                      <EditItemTemplate>
                          <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" Text='<%# Bind("FirstName") %>' placeholder="First Name" />
                      </EditItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="MI">
                      <ItemTemplate><%# Eval("MiddleInitial") %></ItemTemplate>
                      <EditItemTemplate>
                          <asp:TextBox ID="txtEditMiddleInitial" runat="server" CssClass="form-control" Text='<%# Bind("MiddleInitial") %>' placeholder="MI" MaxLength="1" />
                      </EditItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Suffix">
                      <ItemTemplate><%# Eval("Suffix") %></ItemTemplate>
                      <EditItemTemplate>
                          <asp:TextBox ID="txtEditSuffix" runat="server" CssClass="form-control" Text='<%# Bind("Suffix") %>' placeholder="Suffix" />
                      </EditItemTemplate>
                  </asp:TemplateField>

               <asp:TemplateField HeaderText="School ID">
    <ItemTemplate><%# Eval("SchoolID") %></ItemTemplate>
    <EditItemTemplate>
        <asp:TextBox ID="txtEditSchoolID" runat="server" CssClass="form-control" 
            Text='<%# Bind("SchoolID") %>' placeholder="School ID" 
            MaxLength="10"
            onkeypress="return isNumberKey(event)" 
            oninput="validateSchoolID(this)" />
    </EditItemTemplate>
</asp:TemplateField>

                  <asp:TemplateField HeaderText="Email">
                      <ItemTemplate><%# Eval("Email") %></ItemTemplate>
                      <EditItemTemplate>
                          <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" Text='<%# Bind("Email") %>' TextMode="Email" />
                      </EditItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Role">
                      <ItemTemplate><%# Eval("Role") %></ItemTemplate>
                      <EditItemTemplate>
                          <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-select">
                              <asp:ListItem Value="Faculty">Faculty</asp:ListItem>
                              <asp:ListItem Value="Dean">Dean</asp:ListItem>
                              <asp:ListItem Value="Registrar">Registrar</asp:ListItem>
                          </asp:DropDownList>
                      </EditItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="Department">
                      <ItemTemplate><%# Eval("DepartmentName") %></ItemTemplate>
                      <EditItemTemplate>
                          <asp:DropDownList ID="ddlEditDepartment" runat="server" CssClass="form-select"></asp:DropDownList>
                      </EditItemTemplate>
                  </asp:TemplateField>

           <asp:TemplateField HeaderText="Status">
    <ItemTemplate>
        <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
            <i class='bi <%# GetStatusIcon(Eval("Status").ToString()) %> me-1'></i>
            <%# Eval("Status") %>
        </span>
    </ItemTemplate>
    <EditItemTemplate>
        <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select">
            <asp:ListItem Value="Active">Active</asp:ListItem>
            <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
        </asp:DropDownList>
    </EditItemTemplate>
</asp:TemplateField>

                  <asp:TemplateField HeaderText="Actions">
    <ItemTemplate>
        <button type="button" class="btn btn-sm btn-gold me-1" 
                onclick='openEditModal(<%# Eval("UserID") %>, "<%# Eval("LastName") %>", "<%# Eval("FirstName") %>", "<%# Eval("MiddleInitial") %>", "<%# Eval("Suffix") %>", "<%# Eval("SchoolID") %>", "<%# Eval("Email") %>", "<%# Eval("Role") %>", "<%# Eval("DepartmentID") %>", "<%# Eval("Status") %>")'>
            <i class="bi bi-pencil"></i> Edit
        </button>
        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-danger"
            OnClientClick="return confirm('Are you sure you want to delete this user?');">
            <i class="bi bi-trash"></i> Delete
        </asp:LinkButton>
    </ItemTemplate>
</asp:TemplateField>
              </Columns>
              <PagerStyle CssClass="pagination" />
              <PagerSettings Mode="NumericFirstLast" />
          </asp:GridView>
      </div>
  </div>
        <!-- Admin -->
        <div class="tab-pane fade" id="hr" role="tabpanel">
            <div class="table-responsive">
               <asp:GridView ID="gvHR" runat="server" CssClass="table table-striped table-bordered table-hover"
    AutoGenerateColumns="False" DataKeyNames="UserID,Role" AllowPaging="true" PageSize="25"
    OnPageIndexChanging="gv_PageIndexChanging" OnRowEditing="gv_RowEditing"
    OnRowCancelingEdit="gv_RowCancelingEdit" OnRowUpdating="gv_RowUpdating" 
    OnRowDeleting="gv_RowDeleting" OnRowDataBound="gv_RowDataBound">
                    <Columns>
                        <asp:TemplateField HeaderText="Last Name">
                            <ItemTemplate><%# Eval("LastName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" Text='<%# Bind("LastName") %>' placeholder="Last Name" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="First Name">
                            <ItemTemplate><%# Eval("FirstName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" Text='<%# Bind("FirstName") %>' placeholder="First Name" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="MI">
                            <ItemTemplate><%# Eval("MiddleInitial") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditMiddleInitial" runat="server" CssClass="form-control" Text='<%# Bind("MiddleInitial") %>' placeholder="MI" MaxLength="3" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Suffix">
                            <ItemTemplate><%# Eval("Suffix") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditSuffix" runat="server" CssClass="form-control" Text='<%# Bind("Suffix") %>' placeholder="Suffix" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                      <asp:TemplateField HeaderText="School ID">
    <ItemTemplate><%# Eval("SchoolID") %></ItemTemplate>
    <EditItemTemplate>
        <asp:TextBox ID="txtEditSchoolID" runat="server" CssClass="form-control" 
            Text='<%# Bind("SchoolID") %>' placeholder="School ID" 
            MaxLength="10"
            onkeypress="return isNumberKey(event)" 
            oninput="validateSchoolID(this)" />
    </EditItemTemplate>
</asp:TemplateField>

                        <asp:TemplateField HeaderText="Email">
                            <ItemTemplate><%# Eval("Email") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditEmail" runat="server" CssClass="form-control" Text='<%# Bind("Email") %>' TextMode="Email" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate><%# Eval("Role") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Faculty">Faculty</asp:ListItem>
                                    <asp:ListItem Value="Dean">Dean</asp:ListItem>
                                    <asp:ListItem Value="Registrar">Registrar</asp:ListItem>
                                </asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Department">
                            <ItemTemplate><%# Eval("DepartmentName") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditDepartment" runat="server" CssClass="form-select"></asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>

                  <asp:TemplateField HeaderText="Status">
    <ItemTemplate>
        <span class='badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>'>
            <i class='bi <%# GetStatusIcon(Eval("Status").ToString()) %> me-1'></i>
            <%# Eval("Status") %>
        </span>
    </ItemTemplate>
    <EditItemTemplate>
        <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select">
            <asp:ListItem Value="Active">Active</asp:ListItem>
            <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
        </asp:DropDownList>
    </EditItemTemplate>
</asp:TemplateField>

                     <asp:TemplateField HeaderText="Actions">
    <ItemTemplate>
        <button type="button" class="btn btn-sm btn-gold me-1" 
                onclick='openEditModal(<%# Eval("UserID") %>, "<%# Eval("LastName") %>", "<%# Eval("FirstName") %>", "<%# Eval("MiddleInitial") %>", "<%# Eval("Suffix") %>", "<%# Eval("SchoolID") %>", "<%# Eval("Email") %>", "<%# Eval("Role") %>", "<%# Eval("DepartmentID") %>", "<%# Eval("Status") %>")'>
            <i class="bi bi-pencil"></i> Edit
        </button>
        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-danger"
            OnClientClick="return confirm('Are you sure you want to delete this user?');">
            <i class="bi bi-trash"></i> Delete
        </asp:LinkButton>
    </ItemTemplate>
</asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination" />
                    <PagerSettings Mode="NumericFirstLast" />
                </asp:GridView>
            </div>
        </div>

      
    </div>
</div>

<!-- Floating Action Button for Mobile -->
<button type="button" class="btn btn-primary floating-action-btn d-md-none" data-bs-toggle="modal" data-bs-target="#addUserModal">
    <i class="bi bi-person-plus"></i>
</button>
    </form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Global variables
    let addUserModal = null;
    let shouldKeepModalOpen = false;
    let userManuallyClosed = false;

    // Initialize sidebar functionality
    function initializeSidebar() {
        console.log('Initializing sidebar...');

        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('mainContent');
        const sidebarToggler = document.getElementById('sidebarToggler');
        const mobileSidebarToggler = document.getElementById('mobileSidebarToggler');
        const sidebarOverlay = document.getElementById('sidebarOverlay');

        if (!sidebar || !mainContent || !sidebarToggler) {
            console.error('Sidebar elements not found');
            return;
        }

        // Check if we have a saved state in localStorage
        const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';

        // Apply saved state on page load
        if (isCollapsed) {
            sidebar.classList.add('collapsed');
            mainContent.classList.add('collapsed');
            sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
        }

        // Toggle sidebar on button click
        sidebarToggler.addEventListener('click', function () {
            sidebar.classList.toggle('collapsed');
            mainContent.classList.toggle('collapsed');

            // Update button icon
            if (sidebar.classList.contains('collapsed')) {
                sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
                localStorage.setItem('sidebarCollapsed', 'true');
            } else {
                sidebarToggler.innerHTML = '<i class="bi bi-arrow-left-circle"></i>';
                localStorage.setItem('sidebarCollapsed', 'false');
            }
        });

        // Mobile sidebar toggler
        if (mobileSidebarToggler) {
            mobileSidebarToggler.addEventListener('click', function () {
                sidebar.classList.toggle('mobile-show');
                if (sidebarOverlay) {
                    sidebarOverlay.classList.toggle('show');
                }
            });
        }

        // Close sidebar when clicking outside on mobile
        if (sidebarOverlay) {
            sidebarOverlay.addEventListener('click', function () {
                sidebar.classList.remove('mobile-show');
                sidebarOverlay.classList.remove('show');
            });
        }

        // Adjust sidebar on resize
        window.addEventListener('resize', function () {
            if (window.innerWidth >= 768) {
                sidebar.classList.remove('mobile-show');
                if (sidebarOverlay) {
                    sidebarOverlay.classList.remove('show');
                }
            }
        });
    }
    // Preserve active tab during postbacks
    function preserveActiveTab() {
        const activeTab = localStorage.getItem("activeUserTab");
        if (activeTab) {
            const triggerEl = document.querySelector(`[data-bs-target="${activeTab}"]`);
            if (triggerEl && !triggerEl.classList.contains('active')) {
                const tab = new bootstrap.Tab(triggerEl);
                tab.show();
            }
        }
    }

    // Call this on page load and after postbacks
    preserveActiveTab();

    // Save active tab whenever a tab is shown
    document.querySelectorAll('#userTabs button[data-bs-toggle="tab"]').forEach(tab => {
        tab.addEventListener('shown.bs.tab', e => {
            localStorage.setItem("activeUserTab", e.target.getAttribute("data-bs-target"));
        });
    });
    // Initialize modal functionality
    function initializeModal() {
        const modalElement = document.getElementById('addUserModal');
        if (!modalElement) {
            console.error('Modal element not found');
            return;
        }

        // Initialize Bootstrap modal
        addUserModal = new bootstrap.Modal(modalElement);
        window.currentModal = addUserModal;

        // Modal event listeners
        modalElement.addEventListener('hidden.bs.modal', function () {
            console.log('Modal hidden - resetting form');
            resetModalForm();
            shouldKeepModalOpen = false;
            userManuallyClosed = false;
        });

        // Add this to the modal show event listener
        modalElement.addEventListener('show.bs.modal', function () {
            console.log('Modal showing - resetting flags');
            userManuallyClosed = false;
            // Set proper ARIA attributes when modal opens
            modalElement.setAttribute('aria-hidden', 'false');
            modalElement.removeAttribute('inert');

            // Initialize role-based requirements when modal is shown
            updateAddFormRequirements(); // ADD THIS LINE

            // Set focus to first name field for better accessibility
            setTimeout(() => {
                const firstNameField = document.getElementById('<%= txtFirstName.ClientID %>');
        if (firstNameField) firstNameField.focus();
    }, 100);
});

        modalElement.addEventListener('shown.bs.modal', function () {
            console.log('Modal shown');
            shouldKeepModalOpen = false;
            userManuallyClosed = false;

            // Initialize role-based requirements when modal is shown
            initializeRoleBasedRequirements();
        });

        // Close button handlers - USER MANUAL CLOSE (HIGHEST PRIORITY)
        const closeButtons = modalElement.querySelectorAll('[data-bs-dismiss="modal"], .btn-close');
        closeButtons.forEach(button => {
            button.addEventListener('click', function (e) {
                console.log('User manually closing modal - setting highest priority');
                userManuallyClosed = true;
                shouldKeepModalOpen = false;

                // Force close regardless of validation errors
                setTimeout(() => {
                    if (addUserModal) {
                        console.log('Force closing modal due to user action');
                        addUserModal.hide();
                    }
                }, 10);
            });
        });

        // Also handle the cancel button in modal footer specifically
        const cancelButton = modalElement.querySelector('.btn-danger');
        if (cancelButton && cancelButton.textContent.includes('Cancel')) {
            cancelButton.addEventListener('click', function (e) {
                console.log('Cancel button clicked - forcing close');
                userManuallyClosed = true;
                shouldKeepModalOpen = false;

                setTimeout(() => {
                    if (addUserModal) {
                        addUserModal.hide();
                    }
                }, 10);
            });
        }

        // Handle backdrop clicks
        modalElement.addEventListener('click', function (e) {
            if (e.target === modalElement) {
                console.log('Backdrop clicked - allowing close');
                userManuallyClosed = true;
                shouldKeepModalOpen = false;
            }
        });

        // Initialize if modal is already open
        if (modalElement.classList.contains('show')) {
            console.log('Modal already open on page load');
            modalElement.setAttribute('aria-hidden', 'false');
        }
    }

    // Dynamic field requirements for Registrar role
    function initializeRoleBasedRequirements() {
        const roleDropdown = document.getElementById('<%= ddlRole.ClientID %>');
        const emailRequired = document.getElementById('emailRequired');
        const departmentRequired = document.getElementById('departmentRequired');
        const emailField = document.getElementById('<%= txtEmail.ClientID %>');
        const departmentField = document.getElementById('<%= ddlDepartment.ClientID %>');

        if (roleDropdown) {
            roleDropdown.addEventListener('change', function () {
                const selectedRole = this.value;
                updateFieldRequirements(selectedRole);
                updateRoleRestrictionWarning(selectedRole);
            });

            // Trigger on page load
            updateFieldRequirements(roleDropdown.value);
            updateRoleRestrictionWarning(roleDropdown.value);
        }

        // Add real-time validation for email when role changes
        if (emailField && roleDropdown) {
            emailField.addEventListener('blur', function () {
                const selectedRole = roleDropdown.value;
                validateEmailField(emailField, selectedRole);
            });
        }
    }

    function updateFieldRequirements(selectedRole) {
        const emailRequired = document.getElementById('emailRequired');
        const departmentRequired = document.getElementById('departmentRequired');
        const emailField = document.getElementById('<%= txtEmail.ClientID %>');
        const departmentField = document.getElementById('<%= ddlDepartment.ClientID %>');

        // Show/hide required indicators based on role
        if (selectedRole === 'Faculty' || selectedRole === 'Dean') {
            // Email and department required for Faculty and Dean
            if (emailRequired) emailRequired.style.display = 'inline';
            if (departmentRequired) departmentRequired.style.display = 'inline';
        } else if (selectedRole === 'Admin') {
            // Email required but department optional for Admin
            if (emailRequired) emailRequired.style.display = 'inline';
            if (departmentRequired) departmentRequired.style.display = 'none';
        } else if (selectedRole === 'Registrar') {
            // Both email and department optional for Registrar
            if (emailRequired) emailRequired.style.display = 'none';
            if (departmentRequired) departmentRequired.style.display = 'none';
        }

        // Update validation styles
        updateValidationStyles(selectedRole, emailField, departmentField);
    }
    function updateValidationStyles(selectedRole, emailField, departmentField) {
        // Reset all validation first
        if (emailField) {
            emailField.classList.remove('is-invalid', 'is-valid');
        }
        if (departmentField) {
            departmentField.classList.remove('is-invalid', 'is-valid');
        }

        // Apply validation based on role
        if (selectedRole === 'Faculty' || selectedRole === 'Dean') {
            // Both required
            if (emailField && !emailField.value.trim()) {
                emailField.classList.add('is-invalid');
            }
            if (departmentField && !departmentField.value) {
                departmentField.classList.add('is-invalid');
            }
        } else if (selectedRole === 'Admin') {
            // Only email required
            if (emailField && !emailField.value.trim()) {
                emailField.classList.add('is-invalid');
            }
            // Department optional - no validation
        }
        // Registrar - no validation for either
    }

    function updateRoleRestrictionWarning(selectedRole) {
        // Remove existing warning if any
        const existingWarning = document.getElementById('roleRestrictionWarning');
        if (existingWarning) {
            existingWarning.remove();
        }

        if (selectedRole === 'Admin' || selectedRole === 'Registrar') {
            const roleField = document.querySelector('[for="<%= ddlRole.ClientID %>"]');
            if (roleField) {
                const warning = document.createElement('small');
                warning.className = 'text-warning d-block mt-1';
                warning.innerHTML = `<i class="bi bi-info-circle me-1"></i>Role cannot be changed later for ${selectedRole} users`;
                warning.id = 'roleRestrictionWarning';
                roleField.parentNode.appendChild(warning);
            }
        }
    }

    function validateEmailField(emailField, selectedRole) {
        if (selectedRole === 'Registrar') {
            // For Registrar, email is optional but must be valid if provided
            if (emailField.value.trim()) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(emailField.value.trim())) {
                    emailField.classList.add('is-invalid');
                    emailField.classList.remove('is-valid');
                    return false;
                } else {
                    emailField.classList.remove('is-invalid');
                    emailField.classList.add('is-valid');
                    return true;
                }
            } else {
                // Empty email is allowed for Registrar
                emailField.classList.remove('is-invalid', 'is-valid');
                return true;
            }
        } else {
            // For other roles, email is required and must be valid
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailField.value.trim()) {
                emailField.classList.add('is-invalid');
                emailField.classList.remove('is-valid');
                return false;
            } else if (!emailRegex.test(emailField.value.trim())) {
                emailField.classList.add('is-invalid');
                emailField.classList.remove('is-valid');
                return false;
            } else {
                emailField.classList.remove('is-invalid');
                emailField.classList.add('is-valid');
                return true;
            }
        }
    }

    function resetModalForm() {
        const modalMessage = document.getElementById('<%= lblModalMessage.ClientID %>');
        if (modalMessage) {
            modalMessage.textContent = '';
            modalMessage.className = 'alert d-none mb-3';
        }

        // Reset all form fields
        const txtLastName = document.getElementById('<%= txtLastName.ClientID %>');
        const txtFirstName = document.getElementById('<%= txtFirstName.ClientID %>');
        const txtMiddleInitial = document.getElementById('<%= txtMiddleInitial.ClientID %>');
        const txtSuffix = document.getElementById('<%= txtSuffix.ClientID %>');
        const txtSchoolID = document.getElementById('<%= txtSchoolID.ClientID %>');
        const txtEmail = document.getElementById('<%= txtEmail.ClientID %>');
        const ddlRole = document.getElementById('<%= ddlRole.ClientID %>');
        const ddlDepartment = document.getElementById('<%= ddlDepartment.ClientID %>');

        if (txtLastName) txtLastName.value = '';
        if (txtFirstName) txtFirstName.value = '';
        if (txtMiddleInitial) txtMiddleInitial.value = '';
        if (txtSuffix) txtSuffix.value = '';
        if (txtSchoolID) txtSchoolID.value = '';
        if (txtPassword) txtPassword.value = '';
        if (txtEmail) txtEmail.value = '';
        if (ddlRole) ddlRole.selectedIndex = 0;
        if (ddlDepartment) ddlDepartment.selectedIndex = 0;

        // Reset validation styles
        const formFields = [
            txtLastName, txtFirstName, txtSchoolID, txtPassword, txtEmail, ddlDepartment
        ];

        formFields.forEach(field => {
            if (field) {
                field.classList.remove('is-valid', 'is-invalid');
            }
        });

        // Reset role-based requirements
        updateFieldRequirements('');
        updateRoleRestrictionWarning('');
    }

    function setKeepModalOpen(keepOpen) {
        console.log('setKeepModalOpen called with:', keepOpen, 'userManuallyClosed:', userManuallyClosed);

        // If user manually closed, respect their decision and don't keep modal open
        if (userManuallyClosed) {
            console.log('User manually closed modal - ignoring setKeepModalOpen');
            shouldKeepModalOpen = false;
            return;
        }

        shouldKeepModalOpen = keepOpen;
        console.log('Set keep modal open flag to:', shouldKeepModalOpen);

        if (keepOpen && !userManuallyClosed) {
            keepModalOpen();
        }
    }

    function keepModalOpen() {
        console.log('keepModalOpen called - shouldKeepModalOpen:', shouldKeepModalOpen, 'userManuallyClosed:', userManuallyClosed);

        // Only keep open if shouldKeepModalOpen is true AND user hasn't manually closed
        if (shouldKeepModalOpen && !userManuallyClosed) {
            const modalElement = document.getElementById('addUserModal');
            if (modalElement && !modalElement.classList.contains('show')) {
                console.log('Reopening modal after postback - no user manual close detected');
                reopenModal(modalElement);
            }
        } else {
            console.log('Not keeping modal open - user manually closed or flag is false');
        }
    }

    function reopenModal(modalElement) {
        console.log('Reopening modal programmatically');

        // Use Bootstrap's show method for proper handling
        if (addUserModal) {
            addUserModal.show();
        }
    }

    function closeModal() {
        console.log('closeModal called - forcing modal close');
        shouldKeepModalOpen = false;
        userManuallyClosed = false;

        if (addUserModal) {
            addUserModal.hide();
        }
    }

    function forceCloseModal() {
        console.log('forceCloseModal called - overriding all retention logic');
        userManuallyClosed = true;
        shouldKeepModalOpen = false;
        closeModal();
    }

    // Enhanced validation error checking for new field structure
    function checkForValidationErrors() {
        const modalMessage = document.getElementById('<%= lblModalMessage.ClientID %>');
        if (!modalMessage) return false;

        const messageText = modalMessage.textContent.trim();
        const shouldKeepOpen =
            messageText.includes('Please fill in all required fields') ||
            messageText.includes('School ID already exists') ||
            messageText.includes('valid email address') ||
            messageText.includes('already exists') ||
            messageText.includes('Email is required') ||
            messageText.includes('Department is required');

        console.log('Validation check - Message:', messageText, 'Keep open:', shouldKeepOpen);
        return shouldKeepOpen;
    }

    // Check if success message is shown
    function checkForSuccess() {
        const modalMessage = document.getElementById('<%= lblModalMessage.ClientID %>');
        if (!modalMessage) return false;

        const messageText = modalMessage.textContent.trim();
        return messageText.includes('successfully');
    }

    // Prevent bouncing
    function preventBouncing() {
        const updateProgress = document.querySelector('.update-progress');
        if (updateProgress) {
            updateProgress.style.display = 'none';
        }
    }

    // Enhanced form field validation for new structure
    function validateUserForm() {
        const lastName = document.getElementById('<%= txtLastName.ClientID %>');
        const firstName = document.getElementById('<%= txtFirstName.ClientID %>');
        const schoolID = document.getElementById('<%= txtSchoolID.ClientID %>');
        const email = document.getElementById('<%= txtEmail.ClientID %>');
        const role = document.getElementById('<%= ddlRole.ClientID %>');
        const department = document.getElementById('<%= ddlDepartment.ClientID %>');

        if (!lastName || !firstName || !schoolID || !password || !role) {
            return false;
        }

        // Check required fields
        if (!lastName.value.trim() || !firstName.value.trim() || !schoolID.value.trim() || 
            !password.value.trim() || !role.value) {
            return false;
        }

        // Role-based validation
        const selectedRole = role.value;
        if (selectedRole !== 'Registrar') {
            // Email required for non-Registrar roles
            if (!email.value.trim()) {
                return false;
            }
            
            // Department required for non-Registrar roles
            if (!department.value) {
                return false;
            }
            
            // Email validation for non-Registrar roles
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email.value.trim())) {
                return false;
            }
        } else {
            // For Registrar, validate email only if provided
            if (email.value.trim()) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email.value.trim())) {
                    return false;
                }
            }
        }

        return true;
    }

    // Initialize UI components
    function initializeUI() {
        // Handle alert messages
        const alertElement = document.getElementById('<%= lblMessage.ClientID %>');
        if (alertElement && alertElement.textContent.trim() !== '') {
            alertElement.classList.remove('d-none');

            // Auto-hide alert after 5 seconds
            setTimeout(function () {
                if (alertElement) {
                    alertElement.classList.add('d-none');
                }
            }, 5000);
        }

        // Initialize role-based requirements
        initializeRoleBasedRequirements();

        // Check modal state on page load
        setTimeout(function () {
            if (checkForValidationErrors() && !userManuallyClosed) {
                console.log('Validation errors found - keeping modal open');
                setKeepModalOpen(true);
            } else if (checkForSuccess()) {
                console.log('Success message found - closing modal');
                closeModal();
            }
        }, 300);

        // Prevent bouncing
        preventBouncing();

        // Add real-time validation for form fields
        const formFields = [
            '<%= txtLastName.ClientID %>',
            '<%= txtFirstName.ClientID %>',
            '<%= txtSchoolID.ClientID %>',
            '<%= txtEmail.ClientID %>',
            '<%= ddlDepartment.ClientID %>'
        ];

        formFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (field) {
                field.addEventListener('input', function () {
                    if (field.value.trim()) {
                        field.classList.remove('is-invalid');
                    }
                });
            }
        });

        // Auto-format middle initial to uppercase
        const middleInitialField = document.getElementById('<%= txtMiddleInitial.ClientID %>');
        if (middleInitialField) {
            middleInitialField.addEventListener('input', function() {
                this.value = this.value.toUpperCase();
                if (this.value.length > 1) {
                    this.value = this.value.charAt(0);
                }
            });
        }

        // Auto-format suffix to proper case
        const suffixField = document.getElementById('<%= txtSuffix.ClientID %>');
        if (suffixField) {
            suffixField.addEventListener('blur', function () {
                if (this.value) {
                    this.value = this.value
                        .replace(/\b(jr)\b/gi, 'Jr')
                        .replace(/\b(sr)\b/gi, 'Sr')
                        .replace(/\b(ii)\b/gi, 'II')
                        .replace(/\b(iii)\b/gi, 'III')
                        .replace(/\b(iv)\b/gi, 'IV');
                }
            });
        }

        // Enhanced department validation based on role
        const departmentField = document.getElementById('<%= ddlDepartment.ClientID %>');
        const roleField = document.getElementById('<%= ddlRole.ClientID %>');
        if (departmentField && roleField) {
            departmentField.addEventListener('change', function() {
                const selectedRole = roleField.value;
                validateDepartmentField(departmentField, selectedRole);
            });
        }
    }

    // Real-time field validation
    function validateField(field) {
        const roleField = document.getElementById('<%= ddlRole.ClientID %>');
       const selectedRole = roleField ? roleField.value : '';

       // Special handling for email field
       if (field.id === '<%= txtEmail.ClientID %>') {
        validateEmailField(field, selectedRole);
        return;
    }
    
    // Special handling for department field
    if (field.id === '<%= ddlDepartment.ClientID %>') {
        validateDepartmentField(field, selectedRole);
        return;
    }

    // General field validation - only show invalid state, remove valid state
    if (!field.value.trim()) {
        field.classList.add('is-invalid');
    } else {
        field.classList.remove('is-invalid');
    }

    // Special validation for middle initial (max 1 character)
        if (field.id === '<%= txtMiddleInitial.ClientID %>') {
            if (field.value.length > 1) {
                field.value = field.value.charAt(0);
            }
        }
    }

    function validateEmailField(emailField, selectedRole) {
        if (selectedRole === 'Registrar') {
            // For Registrar, email is optional but must be valid if provided
            if (emailField.value.trim()) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(emailField.value.trim())) {
                    emailField.classList.add('is-invalid');
                    return false;
                } else {
                    emailField.classList.remove('is-invalid');
                    return true;
                }
            } else {
                // Empty email is allowed for Registrar
                emailField.classList.remove('is-invalid');
                return true;
            }
        } else {
            // For other roles, email is required and must be valid
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailField.value.trim()) {
                emailField.classList.add('is-invalid');
                return false;
            } else if (!emailRegex.test(emailField.value.trim())) {
                emailField.classList.add('is-invalid');
                return false;
            } else {
                emailField.classList.remove('is-invalid');
                return true;
            }
        }
    }

    function validateDepartmentField(departmentField, selectedRole) {
        if (selectedRole !== 'Registrar') {
            // Department required for non-Registrar roles
            if (!departmentField.value) {
                departmentField.classList.add('is-invalid');
            } else {
                departmentField.classList.remove('is-invalid');
            }
        } else {
            // Department optional for Registrar
            departmentField.classList.remove('is-invalid');
        }
    }

    // Handle page load and async postbacks
    document.addEventListener('DOMContentLoaded', function () {
        console.log('DOM loaded - initializing components');

        // Initialize components
        initializeSidebar();
        initializeModal();
        initializeUI();
        updateAddFormRequirements();
        // Tab persistence
        const savedTab = localStorage.getItem("activeUserTab");
        if (savedTab) {
            const triggerEl = document.querySelector(`[data-bs-target="${savedTab}"]`);
            if (triggerEl) {
                const tab = new bootstrap.Tab(triggerEl);
                tab.show();
            }
        }
        const addRoleDropdown = document.getElementById('<%= ddlRole.ClientID %>');
    if (addRoleDropdown) {
        addRoleDropdown.addEventListener('change', updateAddFormRequirements);
    }
    
        const editRoleDropdown = document.getElementById('<%= ddlEditRole.ClientID %>');
        if (editRoleDropdown) {
            editRoleDropdown.addEventListener('change', updateEditFormRequirements);
        }
    
        document.querySelectorAll('#userTabs button[data-bs-toggle="tab"]').forEach(tab => {
            tab.addEventListener('shown.bs.tab', e => {
                localStorage.setItem("activeUserTab", e.target.getAttribute("data-bs-target"));
            });
        });

        // Add keyboard shortcuts for better UX
        document.addEventListener('keydown', function(e) {
            // Ctrl+Shift+U to open add user modal (when not in input field)
            if (e.ctrlKey && e.shiftKey && e.key === 'U' && 
                !['INPUT', 'TEXTAREA', 'SELECT'].includes(e.target.tagName)) {
                e.preventDefault();
                const addButton = document.querySelector('[data-bs-target="#addUserModal"]');
                if (addButton) addButton.click();
            }
            
            // Escape key to close modal
            if (e.key === 'Escape') {
                const modal = document.getElementById('addUserModal');
                if (modal && modal.classList.contains('show')) {
                    forceCloseModal();
                }
            }
        });

        // Enhanced search functionality
        const searchInput = document.getElementById('<%= txtSearch.ClientID %>');
        const searchButton = document.getElementById('<%= btnSearch.ClientID %>');
        
        if (searchInput && searchButton) {
            // Search on Enter key
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    searchButton.click();
                }
            });
            
            // Clear search when input is emptied
            searchInput.addEventListener('input', function() {
                if (!this.value.trim()) {
                    setTimeout(() => {
                        searchButton.click();
                    }, 300);
                }
            });
        }
    });

    // ASP.NET AJAX support
    if (typeof Sys !== 'undefined') {
        const prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function () {
            console.log('Async postback completed - reinitializing components');
            initializeSidebar();
            initializeModal();
            initializeUI();
            preserveActiveTab(); // Add this line

            // Check if we need to keep modal open after postback
            setTimeout(function () {
                if (checkForValidationErrors() && !userManuallyClosed) {
                    console.log('Validation errors detected after postback - keeping modal open');
                    setKeepModalOpen(true);
                } else if (checkForSuccess()) {
                    console.log('Success detected after postback - closing modal');
                    closeModal();
                }
            }, 100);

            // Re-apply form validation styles after postback
            const formFields = [
            '<%= txtLastName.ClientID %>',
            '<%= txtFirstName.ClientID %>',
            '<%= txtSchoolID.ClientID %>',
            '<%= txtEmail.ClientID %>',
            '<%= ddlDepartment.ClientID %>'
        ];

        formFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (field && field.value.trim()) {
                field.classList.add('is-valid');
            }
        });
    });
}

    // Global exports for server-side access
    window.setKeepModalOpen = setKeepModalOpen;
    window.closeModal = closeModal;
    window.forceCloseModal = forceCloseModal;
    window.validateUserForm = validateUserForm;

    // Helper function to format name display
    function formatUserName(lastName, firstName, middleInitial, suffix) {
        let name = lastName + ', ' + firstName;
        if (middleInitial && middleInitial.trim()) {
            name += ' ' + middleInitial.trim() + '.';
        }
        if (suffix && suffix.trim()) {
            name += ' ' + suffix.trim();
        }
        return name;
    }
    function downloadTemplate() {
        const csvTemplate = "LastName,FirstName,MiddleInitial,Suffix,SchoolID,Email,Role,DepartmentName\n" +
            "Dela Cruz,Juan,A,Jr,FAC001,juan.delacruz@college.edu,Faculty,College of Information Technology\n" +
            "Santos,Maria,R,,FAC002,maria.santos@college.edu,Dean,College of Information Technology\n" +
            "Reyes,Antonio,B,III,FAC003,antonio.reyes@college.edu,Faculty,College of Business\n" +
            "Admin,System,,,ADM001,admin@college.edu,Admin,\n" +
            "Registrar,System,,,REG001,registrar@college.edu,Registrar,";

        const blob = new Blob([csvTemplate], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.setAttribute('hidden', '');
        a.setAttribute('href', url);
        a.setAttribute('download', 'Users_Import_Template.csv');
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }
    // Enhanced error handling
    window.addEventListener('error', function (e) {
        console.error('JavaScript error:', e.error);
    });

    clearUserFileInput();
    
    // Performance monitoring
    let loadTime = window.performance.timing.domContentLoadedEventEnd - window.performance.timing.navigationStart;
    console.log('Page load time: ' + loadTime + 'ms');



    // Function to update sidebar badges
    function updateSidebarBadges() {
        $.ajax({
            type: "POST",
            url: "Users.aspx/GetSidebarBadgeCounts",
            data: "{}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d) {
                    try {
                        const counts = JSON.parse(response.d);

                        // Update enrollment badge
                        const enrollmentBadge = document.getElementById('<%= sidebarEnrollmentBadge.ClientID %>');
                    if (enrollmentBadge) {
                        if (counts.PendingEnrollments > 0) {
                            enrollmentBadge.textContent = counts.PendingEnrollments;
                            enrollmentBadge.style.display = 'flex';
                        } else {
                            enrollmentBadge.style.display = 'none';
                        }
                    }

                    // Update release badge
                    const releaseBadge = document.getElementById('<%= sidebarReleaseBadge.ClientID %>');
                    if (releaseBadge) {
                        if (counts.PendingReleases > 0) {
                            releaseBadge.textContent = counts.PendingReleases;
                            releaseBadge.style.display = 'flex';
                        } else {
                            releaseBadge.style.display = 'none';
                        }
                    }
                } catch (e) {
                    console.log('Error parsing badge counts:', e);
                }
            }
        },
        error: function (xhr, status, error) {
            console.log('Error updating sidebar badges:', error);
        }
    });
    }

    // Call this when page loads and set up interval
    document.addEventListener('DOMContentLoaded', function () {
        // Initial update
        updateSidebarBadges();

        // Update every 30 seconds
        setInterval(updateSidebarBadges, 30000);
    });

    // Auto-refresh every 5 minutes
    setInterval(function () {
        updateSidebarBadges();
    }, 300000); // 5 minutes

    // Open edit modal with user data
    function openEditModal(userID, lastName, firstName, middleInitial, suffix, schoolID, email, role, departmentID, status) {
        // Set hidden field
        document.getElementById('<%= hfEditUserID.ClientID %>').value = userID;

        // Populate form fields
        document.getElementById('<%= txtEditLastName.ClientID %>').value = lastName || '';
        document.getElementById('<%= txtEditFirstName.ClientID %>').value = firstName || '';
        document.getElementById('<%= txtEditMiddleInitial.ClientID %>').value = middleInitial || '';
        document.getElementById('<%= txtEditSuffix.ClientID %>').value = suffix || '';
    document.getElementById('<%= txtEditSchoolID.ClientID %>').value = schoolID || '';
    document.getElementById('<%= txtEditEmail.ClientID %>').value = email || '';
    
    // Set dropdown values
    setDropdownValue('<%= ddlEditRole.ClientID %>', role);
    setDropdownValue('<%= ddlEditDepartment.ClientID %>', departmentID);
        setDropdownValue('<%= ddlEditStatus.ClientID %>', status);

        // Update form requirements based on role - this will hide/show department
        updateEditFormRequirements();

        // Show modal
        showEditModal();
    }

function setDropdownValue(dropdownId, value) {
    const dropdown = document.getElementById(dropdownId);
    if (dropdown && value) {
        for (let i = 0; i < dropdown.options.length; i++) {
            if (dropdown.options[i].value === value) {
                dropdown.selectedIndex = i;
                break;
            }
        }
    }
}

function showEditModal() {
    const editModal = new bootstrap.Modal(document.getElementById('editUserModal'));
    editModal.show();
}

function closeEditModal() {
    const editModal = bootstrap.Modal.getInstance(document.getElementById('editUserModal'));
    if (editModal) {
        editModal.hide();
    }
    // Clear form
    document.getElementById('<%= lblEditMessage.ClientID %>').textContent = '';
    document.getElementById('<%= lblEditMessage.ClientID %>').className = 'alert d-none mb-3';
}

// Update form requirements for edit modal
    function updateEditFormRequirements() {
        const role = document.getElementById('<%= ddlEditRole.ClientID %>').value;
    const departmentRequired = document.getElementById('editDepartmentRequired');
       const departmentField = document.getElementById('<%= ddlEditDepartment.ClientID %>');
       const departmentSection = document.querySelector('#editUserModal .department-field');
       const departmentHelp = document.getElementById('editDepartmentHelp');

       if (role === 'Faculty' || role === 'Dean') {
           // Show department section for Faculty and Dean
           if (departmentSection) departmentSection.style.display = 'block';
           if (departmentRequired) departmentRequired.style.display = 'inline';
           if (departmentField) {
               departmentField.required = true;
               departmentField.disabled = false;
           }
           if (departmentHelp) departmentHelp.style.display = 'block';
       } else {
           // Hide entire department section for Admin and Registrar
           if (departmentSection) departmentSection.style.display = 'none';
           if (departmentRequired) departmentRequired.style.display = 'none';
           if (departmentField) {
               departmentField.required = false;
               // Clear selection for non-faculty/dean roles
               if (role === 'Admin' || role === 'Registrar') {
                   departmentField.selectedIndex = 0;
               }
           }
           if (departmentHelp) departmentHelp.style.display = 'none';
       }
   }

// Initialize edit form requirements when role changes
document.addEventListener('DOMContentLoaded', function() {
    const editRoleDropdown = document.getElementById('<%= ddlEditRole.ClientID %>');
    if (editRoleDropdown) {
        editRoleDropdown.addEventListener('change', updateEditFormRequirements);
    }
    
    // Also update add form requirements for email
    const addRoleDropdown = document.getElementById('<%= ddlRole.ClientID %>');
    if (addRoleDropdown) {
        addRoleDropdown.addEventListener('change', function() {
            updateAddFormRequirements();
        });
    }
});

// Update add form requirements - Email required for ALL roles
    function updateAddFormRequirements() {
        const role = document.getElementById('<%= ddlRole.ClientID %>').value;
    const emailRequired = document.getElementById('emailRequired');
    const departmentRequired = document.getElementById('departmentRequired');
       const departmentField = document.getElementById('<%= ddlDepartment.ClientID %>');
       const departmentSection = document.querySelector('#addUserModal .department-field');
       const departmentHelp = document.getElementById('departmentHelp');

       // Email is always required for all roles
       if (emailRequired) emailRequired.style.display = 'inline';

       if (role === 'Faculty' || role === 'Dean') {
           // Show department section for Faculty and Dean
           if (departmentSection) departmentSection.style.display = 'block';
           if (departmentRequired) departmentRequired.style.display = 'inline';
           if (departmentField) {
               departmentField.required = true;
               departmentField.disabled = false;
           }
           if (departmentHelp) departmentHelp.style.display = 'block';
       } else {
           // Hide entire department section for Admin and Registrar
           if (departmentSection) departmentSection.style.display = 'none';
           if (departmentRequired) departmentRequired.style.display = 'none';
           if (departmentField) {
               departmentField.required = false;
               // Clear selection for non-faculty/dean roles
               if (role === 'Admin' || role === 'Registrar') {
                   departmentField.selectedIndex = 0;
               }
           }
           if (departmentHelp) departmentHelp.style.display = 'none';
       }
   }
    // School ID validation
    function isNumberKey(evt) {
        const charCode = (evt.which) ? evt.which : evt.keyCode;
        return !(charCode > 31 && (charCode < 48 || charCode > 57));
    }

    function validateSchoolID(input) {
        const errorDiv = document.getElementById('schoolIDError');
        if (!/^\d*$/.test(input.value)) {
            input.classList.add('is-invalid');
            if (errorDiv) errorDiv.style.display = 'block';
        } else {
            input.classList.remove('is-invalid');
            if (errorDiv) errorDiv.style.display = 'none';
        }
    }
    function validateFileUpload() {
        const fileUpload = document.getElementById('<%= fuImport.ClientID %>');
        const importMessage = document.getElementById('<%= lblImportMessage.ClientID %>');

        if (!fileUpload || !fileUpload.files || fileUpload.files.length === 0) {
            if (importMessage) {
                importMessage.textContent = '⚠ Please select a CSV file to upload.';
                importMessage.className = 'alert alert-danger d-block mb-3';
            }
            return false;
        }

        const file = fileUpload.files[0];
        const fileExtension = file.name.split('.').pop().toLowerCase();

        if (fileExtension !== 'csv') {
            if (importMessage) {
                importMessage.textContent = '⚠ Please upload a valid CSV file.';
                importMessage.className = 'alert alert-danger d-block mb-3';
            }
            return false;
        }

        if (file.size > 10485760) { // 10MB
            if (importMessage) {
                importMessage.textContent = '⚠ File size exceeds 10MB limit.';
                importMessage.className = 'alert alert-danger d-block mb-3';
            }
            return false;
        }

        // Clear any previous messages
        if (importMessage) {
            importMessage.textContent = '';
            importMessage.className = 'alert d-none mb-3';
        }

        return true;
    }

    // Update the downloadTemplate function to match the Users template
   
</script>
</body>
</html>




