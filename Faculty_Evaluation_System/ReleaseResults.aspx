<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ReleaseResults.aspx.vb" Inherits="Faculty_Evaluation_System.ReleaseResults" EnableEventValidation="false" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Release Results - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        /* Consistent color variables with Students.aspx */
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
        
        /* Header styling - consistent with Students.aspx */
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
        
        /* Sidebar styling - consistent with Students.aspx */
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
        
        /* Main content - consistent with Students.aspx */
        .content {
            margin-left: var(--sidebar-width);
            margin-top: var(--header-height);
            padding: 1.5rem;
            transition: all 0.3s ease;
            width: calc(100% - var(--sidebar-width));
            min-height: calc(100vh - var(--header-height));
        }
        
        .content.collapsed {
            margin-left: var(--sidebar-collapsed-width);
            width: calc(100% - var(--sidebar-collapsed-width));
        }
        
        /* Card styling - consistent with Students.aspx */
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
        
        /* Button styling - consistent with Students.aspx */
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }
        
        .btn-success {
            background-color: var(--success);
            border-color: var(--success);
        }
        
        .btn-danger {
            background-color: var(--danger);
            border-color: var(--danger);
        }
        
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
        
        .btn-outline-primary {
            color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary);
            color: white;
        }
        
        .btn-outline-secondary {
            color: var(--secondary);
            border-color: var(--secondary);
        }
        
        .btn-outline-secondary:hover {
            background-color: var(--secondary);
            border-color: var(--secondary);
            color: white;
        }
        
        /* Form controls - consistent with Students.aspx */
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
        }
        
        /* Table styling - consistent with Students.aspx */
        .table th {
            border-top: none;
            font-weight: 700;
            color: var(--dark);
            background-color: #f8f9fc;
        }
        
        .table-hover tbody tr:hover {
            background-color: rgba(26, 58, 143, 0.05);
        }
        
        /* Badge styling - consistent with Students.aspx */
        .badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.35rem 0.65rem;
        }
        
        .bg-primary {
            background-color: var(--primary) !important;
        }
        
        .bg-secondary {
            background-color: var(--secondary) !important;
        }
        
        .bg-success {
            background-color: var(--success) !important;
        }
        
        .bg-warning {
            background-color: var(--warning) !important;
            color: #333 !important;
        }
        
        /* Page title - consistent with Students.aspx */
        .page-title {
            color: var(--primary);
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.5rem;
        }
        
        .gold-accent {
            color: var(--gold);
        }
        
        /* Alert styling - consistent with Students.aspx */
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
        
        /* Status styling */
        .status-released {
            color: var(--success);
            font-weight: 600;
        }
        
        .status-ready {
            color: var(--warning);
            font-weight: 600;
        }
        
        /* Bulk actions styling */
        #bulkActionsCard {
            border-left: 4px solid var(--success);
        }
        
        .faculty-checkbox {
            transform: scale(1.1);
        }
        
        .form-check-input:checked {
            background-color: var(--primary);
            border-color: var(--primary);
        }
        
        /* Disable checkboxes for already released faculty */
        .faculty-checkbox[data-is-released="2"] {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        /* Better visual feedback for selected rows */
        .table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .table tbody tr:has(.faculty-checkbox:checked) {
            background-color: #e8f5e8;
            border-left: 3px solid var(--success);
        }
        
        /* Bulk actions card styling */
        #bulkActionsCard {
            border-left: 4px solid var(--success);
            background-color: #f8fff8;
        }
        
        /* Visual styling for checkboxes based on status */
        .faculty-checkbox[data-is-released="0"] {
            /* Ready to release - normal appearance */
        }
        
        .faculty-checkbox[data-is-released="2"] {
            opacity: 0.7;
        }
        
        /* Row highlighting based on status and selection */
        .table tbody tr:has(.faculty-checkbox[data-is-released="0"]) {
            border-left: 3px solid var(--success);
        }
        
        .table tbody tr:has(.faculty-checkbox[data-is-released="2"]) {
            border-left: 3px solid var(--secondary);
        }
        
        .table tbody tr:has(.faculty-checkbox[data-is-released="0"]:checked) {
            background-color: #e8f5e8;
        }
        
        .table tbody tr:has(.faculty-checkbox[data-is-released="2"]:checked) {
            background-color: #fff3cd;
        }
        
        /* Sidebar toggler - consistent with Students.aspx */
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
        
        /* Logo styling - consistent with Students.aspx */
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
        
        /* Mobile sidebar overlay - consistent with Students.aspx */
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
        
        /* Responsive adjustments - consistent with Students.aspx */
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
                width: 100%;
            }
            
            .content.collapsed {
                margin-left: 0;
                width: 100%;
            }
            
            .header-title {
                font-size: 1.25rem;
            }
            
            .header-bar .title-section h3 {
                font-size: 1rem !important;
            }
            
            .header-bar .title-section small {
                font-size: 0.65rem !important;
            }
            
            .sidebar-toggler {
                left: 10px;
                bottom: 10px;
            }
            
            .header-bar {
                padding: 0.75rem 1rem;
            }
            
            .header-bar .dropdown-toggle {
                padding: 0.375rem 0.5rem;
                font-size: 0.875rem;
            }
            
            .sidebar .list-group-item {
                padding: 1rem 1.5rem;
            }
            
            .btn {
                padding: 0.5rem 0.75rem;
            }
            
            .card-body {
                padding: 1rem;
            }
            
            /* Bulk actions responsive */
            #bulkActionsCard .text-end {
                text-align: left !important;
                margin-top: 1rem;
            }
            
            #bulkActionsCard .btn {
                width: 100%;
                margin-bottom: 0.5rem;
            }
            
            .content .d-flex.justify-content-between h3 {
                font-size: 1.5rem;
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
        
        /* Improved checkbox styling */
        .faculty-checkbox:disabled {
            opacity: 0.5;
            cursor: not-allowed !important;
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
/* Enhanced Table Styling - Consistent with AdminConfirmEnrollment.aspx */
.student-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 0;
}

.student-table th {
    background-color: #f8f9fa;
    padding: 0.75rem;
    text-align: left;
    font-weight: 600;
    border-bottom: 2px solid #dee2e6;
    color: var(--dark);
}

.student-table td {
    padding: 0.75rem;
    border-bottom: 1px solid #dee2e6;
    vertical-align: middle;
}

.student-table tr:hover {
    background-color: #f8f9fa;
}

.status-badge {
    font-size: 0.75rem;
    padding: 0.25rem 0.5rem;
}

/* Action buttons styling */
.btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
}

/* Checkbox styling */
.row-checkbox {
    transform: scale(1.1);
}

.form-check-input:checked {
    background-color: var(--primary);
    border-color: var(--primary);
}
/* Responsive table adjustments */
@media (max-width: 768px) {
    .student-table {
        font-size: 0.875rem;
    }
    
    .student-table th,
    .student-table td {
        padding: 0.5rem;
    }
    
    /* Hide email column on smaller screens */
    .student-table th:nth-child(4),
    .student-table td:nth-child(4) {
        display: none;
    }
    
    .btn-sm {
        padding: 0.2rem 0.4rem;
        font-size: 0.8rem;
    }
    
    .status-badge {
        font-size: 0.7rem;
        padding: 0.2rem 0.4rem;
    }
}

@media (max-width: 576px) {
    /* Hide department column on very small screens */
    .student-table th:nth-child(3),
    .student-table td:nth-child(3) {
        display: none;
    }
    
    /* Stack bulk action buttons on mobile */
    .bulk-actions .text-end {
        text-align: left !important;
    }
    
    .bulk-actions .btn {
        width: 100%;
        margin: 0.25rem 0;
    }
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
                    <img src="Image/logo.png" alt="GWC Logo" class="header-logo me-2" 
                         onerror="this.style.display='none'" />
                    <div class="title-section">
                        <h3 class="mb-0 fw-bold text-white">Golden West Colleges Inc.</h3>
                        <small class="text-white-50">Faculty Evaluation System (Admin Dashboard)</small>
                    </div>
                </div>
            </div>
            <div class="d-flex align-items-center">
                <!-- User Menu -->
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
              <a href="ReleaseResults.aspx" class="list-group-item list-group-item-action position-relative active">
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
    <div id="alertContainer">
        <asp:Label ID="lblAlert" runat="server" CssClass="alert d-none" />
    </div>

    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="dashboard-title"><i class="bi bi-send-check me-2 gold-accent"></i>Release Evaluation Results</h3>
    </div>

    <!-- Filters -->
    <div class="card mb-3">
        <div class="card-body py-2">
            <div class="row g-2 align-items-end">
                <div class="col-md-8">
                    <label class="form-label fw-bold small mb-1">Search Faculty</label>
                     <div class="col-md-6">
     <div class="input-group">
         <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search Faculty..." />
         <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-secondary" OnClick="btnSearch_Click" />
     </div>
 </div>
                </div>
            </div>
        </div>
    </div>

 <div class="bulk-actions card mb-3" id="bulkActionsCard" runat="server" style="display: none;">
    <div class="card-body py-2">
        <div class="row align-items-center">
            <div class="col-md-6">
                <span class="fw-bold text-primary" id="selectedCount">
                    <i class="bi bi-check2-circle me-1"></i>
                    <span>0 faculty selected</span>
                </span>
            </div>
            <div class="col-md-6 text-end">
                <asp:Button ID="btnReleaseSelected" runat="server" Text="Release Selected" 
                          CssClass="btn btn-success btn-sm me-2" OnClick="btnReleaseSelected_Click" />
                <asp:Button ID="btnRevokeSelected" runat="server" Text="Revoke Selected" 
                          CssClass="btn btn-danger btn-sm" OnClick="btnRevokeSelected_Click" />
            </div>
        </div>
    </div>
</div>

    <!-- Faculty List -->
    <div class="card">
        <div class="card-header py-2">
            <div class="d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center">
                    <i class="bi bi-list-ul me-2"></i>
                    <span class="fw-bold">Faculty Members (All Grade Submissions Confirmed)</span>
                </div>
                <div>
                    <asp:Label ID="lblResultsCount" runat="server" CssClass="badge bg-primary"></asp:Label>
                </div>
            </div>
        </div>
        <div class="card-body p-0">
            <asp:Panel ID="pnlNoResults" runat="server" Visible="false" CssClass="text-center py-4">
                <i class="bi bi-people display-4 text-muted"></i>
                <h5 class="text-muted mt-3">No Faculty Found</h5>
                <p class="text-muted small">No faculty have all their grade submissions confirmed yet.</p>
            </asp:Panel>
<div class="table-responsive">
    <asp:GridView ID="gvFaculty" runat="server" AutoGenerateColumns="False" 
                CssClass="student-table" DataKeyNames="FacultyID" 
                OnRowDataBound="gvFaculty_RowDataBound" 
                OnRowCommand="gvFaculty_RowCommand" ShowHeaderWhenEmpty="true">
        <Columns>
            <asp:TemplateField>
                <HeaderTemplate>
                    <asp:CheckBox ID="chkSelectAll" runat="server" onclick="toggleSelectAll(this)" />
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:CheckBox ID="chkSelect" runat="server" CssClass="row-checkbox faculty-checkbox" 
                                data-is-released='<%# Eval("IsReleased") %>' />
                </ItemTemplate>
                <ItemStyle Width="50px" />
            </asp:TemplateField>
            <asp:BoundField DataField="FullName" HeaderText="Faculty Name" SortExpression="FullName" />
            <asp:BoundField DataField="DepartmentName" HeaderText="Department" SortExpression="DepartmentName" />
            <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
            <asp:TemplateField HeaderText="Status" SortExpression="IsReleased">
                <ItemTemplate>
                    <asp:Label ID="lblStatus" runat="server" CssClass="status-badge badge"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Actions">
                <ItemTemplate>
                    <asp:LinkButton ID="btnAction" runat="server" 
                        Text='<%# IIf(Eval("IsReleased").ToString() = "2", "Revoke", "Release") %>' 
                        CommandName='<%# IIf(Eval("IsReleased").ToString() = "2", "Revoke", "Release") %>' 
                        CommandArgument='<%# Eval("FacultyID") %>' 
                        CssClass='<%# IIf(Eval("IsReleased").ToString() = "2", "btn btn-danger btn-sm", "btn btn-success btn-sm") %>'
                        OnClientClick='<%# GetConfirmationScript(Eval("IsReleased"), Eval("FullName")) %>' />
                </ItemTemplate>
                <ItemStyle Width="120px" />
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            <div class="text-center py-4">
                <i class="bi bi-people display-4 text-muted"></i>
                <h5 class="text-muted mt-3">No Faculty Found</h5>
                <p class="text-muted small">No faculty have all their grade submissions confirmed yet.</p>
            </div>
        </EmptyDataTemplate>
    </asp:GridView>
</div>
        </div>
    </div>
</div>
    </form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    // Mobile detection and responsive adjustments
    const isMobile = window.innerWidth <= 768;

    // Toggle sidebar
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');
    const sidebarToggler = document.getElementById('sidebarToggler');
    const mobileSidebarToggler = document.getElementById('mobileSidebarToggler');
    const sidebarOverlay = document.getElementById('sidebarOverlay');

    // Initialize sidebar state
    function initializeSidebar() {
        // Check if we have a saved state in localStorage (only for desktop)
        const isCollapsed = !isMobile && localStorage.getItem('sidebarCollapsed') === 'true';

        // Apply saved state on page load
        if (isCollapsed) {
            sidebar.classList.add('collapsed');
            mainContent.classList.add('collapsed');
            if (sidebarToggler) {
                sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
            }
        }
    }

    // Toggle sidebar on button click (desktop)
    function setupSidebarToggler() {
        if (sidebarToggler) {
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

                // Fix badge positions after toggle
                setTimeout(fixBadgePositions, 300);
            });
        }
    }

    // Mobile sidebar toggler
    function setupMobileSidebar() {
        if (mobileSidebarToggler) {
            mobileSidebarToggler.addEventListener('click', function () {
                sidebar.classList.toggle('mobile-show');
                sidebarOverlay.classList.toggle('show');
                document.body.style.overflow = sidebar.classList.contains('mobile-show') ? 'hidden' : '';

                // Fix badge positions when mobile sidebar opens
                if (sidebar.classList.contains('mobile-show')) {
                    setTimeout(fixBadgePositions, 300);
                }
            });
        }

        // Close sidebar when clicking outside on mobile
        if (sidebarOverlay) {
            sidebarOverlay.addEventListener('click', function () {
                sidebar.classList.remove('mobile-show');
                sidebarOverlay.classList.remove('show');
                document.body.style.overflow = '';
            });
        }
    }

    // Handle alert messages with better mobile styling
    function setupAlerts() {
        const alertElement = document.getElementById('<%= lblAlert.ClientID %>');
        if (alertElement && alertElement.textContent.trim() !== '') {
            alertElement.classList.remove('d-none');
            alertElement.classList.add('alert-slide');

            // Auto-hide alert after 5 seconds
            setTimeout(function () {
                if (alertElement) {
                    alertElement.classList.remove('alert-slide');
                    setTimeout(() => {
                        if (alertElement) {
                            alertElement.classList.add('d-none');
                        }
                    }, 500);
                }
            }, 5000);
        }
    }

    // Enhanced bulk selection functions
    function toggleSelectAll(source) {
        const checkboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"])');
        const isChecked = source.checked;

        checkboxes.forEach(checkbox => {
            if (!checkbox.disabled) {
                checkbox.checked = isChecked;
                // Update row visual state
                const row = checkbox.closest('tr');
                if (row) {
                    row.classList.toggle('table-active', isChecked);
                }
            }
        });
        updateBulkActions();
    }

    function updateBulkActions() {
        const checkboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"]):checked');
        const bulkActions = document.getElementById('<%= bulkActionsCard.ClientID %>');
        const selectedCount = document.getElementById('selectedCount');
        const totalCheckboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"])').length;
        const enabledCheckboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"]):not(:disabled)').length;

        if (selectedCount) {
            selectedCount.textContent = `${checkboxes.length} faculty selected`;
        }

        if (bulkActions) {
            if (checkboxes.length > 0) {
                bulkActions.style.display = 'block';

                // Add visual feedback
                setTimeout(() => {
                    bulkActions.style.transform = 'scale(1.02)';
                    setTimeout(() => {
                        bulkActions.style.transform = 'scale(1)';
                    }, 150);
                }, 10);
            } else {
                bulkActions.style.display = 'none';
            }
        }

        // Update select all checkbox state
        const selectAllCheckbox = document.querySelector('input[id*="chkSelectAll"]');
        if (selectAllCheckbox) {
            const checkedEnabled = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"]):checked:not(:disabled)').length;
            selectAllCheckbox.checked = checkedEnabled === enabledCheckboxes && enabledCheckboxes > 0;
            selectAllCheckbox.indeterminate = checkedEnabled > 0 && checkedEnabled < enabledCheckboxes;
        }
    }

    // Setup checkbox event listeners
    function setupCheckboxEvents() {
        // Update bulk actions when any row checkbox is clicked
        document.addEventListener('change', function (e) {
            if (e.target && e.target.matches('input[id*="chkSelect"]:not([id*="chkSelectAll"])')) {
                updateBulkActions();

                // Visual feedback for row selection
                const row = e.target.closest('tr');
                if (row) {
                    row.classList.toggle('table-active', e.target.checked);
                }
            }
        });
    }

    // Bulk action confirmations
    function setupBulkActionConfirmations() {
        const bulkRelease = document.getElementById('<%= btnReleaseSelected.ClientID %>');
        if (bulkRelease) {
            bulkRelease.addEventListener('click', function (e) {
                const selectedCount = getSelectedFacultyCount();
                if (selectedCount === 0) {
                    alert('Please select at least one faculty member.');
                    e.preventDefault();
                    return;
                }
                if (!confirm(`Are you sure you want to release results for ${selectedCount} selected faculty member(s)?`)) {
                    e.preventDefault();
                } else {
                    // Add loading state
                    this.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status"></span>Releasing...';
                    this.disabled = true;
                }
            });
        }

        const bulkRevoke = document.getElementById('<%= btnRevokeSelected.ClientID %>');
        if (bulkRevoke) {
            bulkRevoke.addEventListener('click', function (e) {
                const selectedCount = getSelectedFacultyCount();
                if (selectedCount === 0) {
                    alert('Please select at least one faculty member.');
                    e.preventDefault();
                    return;
                }
                if (!confirm(`Are you sure you want to revoke results for ${selectedCount} selected faculty member(s)?`)) {
                    e.preventDefault();
                } else {
                    // Add loading state
                    this.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status"></span>Revoking...';
                    this.disabled = true;
                }
            });
        }
    }

    function getSelectedFacultyCount() {
        const checkboxes = document.querySelectorAll('input[id*="chkSelect"]:not([id*="chkSelectAll"]):checked:not(:disabled)');
        return checkboxes.length;
    }

    // Enhanced table responsiveness
    function enhanceTableResponsiveness() {
        const table = document.querySelector('.student-table');
        if (!table) return;

        function adjustTableLayout() {
            const isSmallScreen = window.innerWidth <= 768;
            
            if (isSmallScreen) {
                table.classList.add('small-screen');
                // Add responsive table headers as data attributes
                const headers = table.querySelectorAll('th');
                const cells = table.querySelectorAll('td');
                
                headers.forEach((header, index) => {
                    cells.forEach(cell => {
                        if (cell.cellIndex === index) {
                            cell.setAttribute('data-label', header.textContent);
                        }
                    });
                });
            } else {
                table.classList.remove('small-screen');
            }
        }

        // Initial adjustment
        adjustTableLayout();
        
        // Adjust on resize
        window.addEventListener('resize', adjustTableLayout);
    }

    // Fix badge positioning - UPDATED FOR SIDEBAR BADGES
    function fixBadgePositions() {
        // Fix enrollment badge
        const enrollmentBadge = document.getElementById('<%= sidebarEnrollmentBadge.ClientID %>');
        fixSingleBadge(enrollmentBadge);
        
        // Fix release results badge - THIS IS THE ONE WE NEED TO FIX
        const releaseBadge = document.getElementById('<%= sidebarReleaseBadge.ClientID %>');
        fixSingleBadge(releaseBadge);
        
        console.log('Badges fixed:', {
            enrollmentBadge: enrollmentBadge?.textContent,
            releaseBadge: releaseBadge?.textContent
        });
    }

    function fixSingleBadge(badge) {
        if (badge && badge.offsetParent) {
            console.log('Fixing badge:', badge.textContent);
            
            // Remove any problematic classes that might interfere
            badge.classList.remove('position-absolute', 'top-0', 'start-100', 'translate-middle');
            
            // Force inline styles for positioning
            badge.style.position = 'absolute';
            badge.style.top = '8px';
            badge.style.right = '12px';
            badge.style.transform = 'none';
            badge.style.zIndex = '1000';
            badge.style.display = 'inline-flex';
            badge.style.alignItems = 'center';
            badge.style.justifyContent = 'center';
            
            // Ensure the badge is visible if it has content
            if (badge.textContent && badge.textContent.trim() !== '' && badge.textContent !== '0') {
                badge.style.visibility = 'visible';
                badge.style.opacity = '1';
            }

            // Ensure parent has relative positioning
            const parent = badge.parentElement;
            if (parent) {
                parent.style.position = 'relative';
            }
        } else if (badge) {
            console.log('Badge parent not visible:', badge.textContent);
        }
    }

    // Touch device enhancements
    function setupTouchEnhancements() {
        if ('ontouchstart' in window) {
            // Increase tap targets for mobile
            document.addEventListener('DOMContentLoaded', function() {
                const buttons = document.querySelectorAll('.btn, .list-group-item');
                buttons.forEach(button => {
                    button.style.minHeight = '44px';
                    if (button.classList.contains('list-group-item')) {
                        button.style.paddingTop = '12px';
                        button.style.paddingBottom = '12px';
                    }
                });
            });
        }
    }

    // Adjust sidebar on resize
    function setupResponsiveBehavior() {
        window.addEventListener('resize', function () {
            if (window.innerWidth >= 768) {
                sidebar.classList.remove('mobile-show');
                if (sidebarOverlay) {
                    sidebarOverlay.classList.remove('show');
                }
                document.body.style.overflow = '';
            }
            
            // Re-fix badges on resize
            setTimeout(fixBadgePositions, 100);
        });
    }

    // Prevent horizontal scroll on mobile
    function preventHorizontalScroll() {
        window.addEventListener('load', function() {
            document.body.style.overflowX = 'hidden';
        });
    }

    // Initialize everything when DOM is loaded
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Initializing Release Results page...');
        
        initializeSidebar();
        setupSidebarToggler();
        setupMobileSidebar();
        setupAlerts();
        setupCheckboxEvents();
        setupBulkActionConfirmations();
        enhanceTableResponsiveness();
        setupTouchEnhancements();
        setupResponsiveBehavior();
        preventHorizontalScroll();
        
        // Initialize bulk actions
        updateBulkActions();
        
        // Fix badge positions after everything is loaded
        setTimeout(fixBadgePositions, 500);
        
        console.log('Page initialization complete');
    });

    // Global function for badge updates (can be called from WebMethod)
    window.updateSidebarBadges = function(counts) {
        try {
            if (counts.PendingReleases > 0) {
                const releaseBadge = document.getElementById('<%= sidebarReleaseBadge.ClientID %>');
                if (releaseBadge) {
                    releaseBadge.textContent = counts.PendingReleases;
                    releaseBadge.style.display = 'inline-flex';
                    fixSingleBadge(releaseBadge);
                }
            }
        } catch (e) {
            console.error('Error updating sidebar badges:', e);
        }
    };

    // Auto-refresh badge counts every 30 seconds
    setInterval(function () {
        try {
            // This would call your WebMethod to get updated counts
            // For now, we'll just refix the positions
            fixBadgePositions();
        } catch (e) {
            console.error('Error in auto-refresh:', e);
        }
    }, 30000);
</script>

</body>
</html>


