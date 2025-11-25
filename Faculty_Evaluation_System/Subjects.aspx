<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Subjects.aspx.vb" Inherits="Faculty_Evaluation_System.Subjects" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Subjects - Faculty Evaluation System</title>
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
        .add-subject-form .row {
            flex-direction: column;
        }
        
        .add-subject-form .col-md-3,
        .add-subject-form .col-md-5,
        .add-subject-form .col-md-2 {
            width: 100%;
            margin-bottom: 1rem;
        }
        
        .add-subject-form .btn {
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
    
    /* Add Subject form styling */
    .add-subject-form {
        background-color: #f8f9fc;
        border-radius: 0.35rem;
        padding: 1.5rem;
    }
    
    /* Input group styling */
    .input-group-text {
        background-color: #e9ecef;
        border-color: #ced4da;
        color: #495057;
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
    
    /* Icon styling with Golden West colors */
    .text-primary {
        color: var(--primary) !important;
    }
    
    .text-info {
        color: var(--primary-light) !important;
    }
    
    /* Form focus states */
    .form-control:focus, .form-select:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
    }
    
    /* Table icon styling */
    .table th i {
        color: var(--primary);
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
    
    /* Subject card styling */
    .subject-card {
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    
    .subject-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
    }
    /* Modal Styling */
.modal-header {
    border-bottom: 2px solid var(--gold);
}

.modal-footer {
    border-top: 1px solid #dee2e6;
}

/* Import Statistics */
.stat-item {
    text-align: center;
    padding: 0.5rem;
}

.stat-value {
    font-size: 1.5rem;
    font-weight: bold;
    display: block;
}

.stat-success { color: var(--success); }
.stat-danger { color: var(--danger); }
.stat-warning { color: var(--warning); }
.stat-info { color: var(--info); }

/* Progress Bar */
.progress {
    border-radius: 10px;
    overflow: hidden;
}

.progress-bar {
    transition: width 0.3s ease;
}

/* Preview Table */
#previewTable {
    font-size: 0.875rem;
}

#previewTable th {
    background-color: var(--primary);
    color: white;
    font-weight: 600;
}

/* File Upload Styling */
.file-upload-container {
    border: 2px dashed #dee2e6;
    border-radius: 0.375rem;
    padding: 2rem;
    text-align: center;
    transition: all 0.3s ease;
    background-color: #f8f9fc;
}

.file-upload-container.dragover {
    border-color: var(--primary);
    background-color: rgba(26, 58, 143, 0.05);
}

/* Modal Responsive */
@media (max-width: 768px) {
    .modal-dialog {
        margin: 1rem;
    }
    
    .stat-value {
        font-size: 1.25rem;
    }
    
    .modal-footer .btn {
        width: 100%;
        margin-bottom: 0.5rem;
    }
    
    .modal-footer {
        flex-direction: column;
    }
}
/* Updated Import Modal Styling */
.modal-header {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
    color: white;
    border-bottom: 3px solid var(--gold);
    padding: 1rem 1.5rem;
}

.modal-header .btn-close {
   
    opacity: 0.8;
    transition: all 0.3s ease;
}

.modal-header .btn-close:hover {
    opacity: 1;
    transform: scale(1.1);
}

.modal-content {
    border: 2px solid var(--primary);
    border-radius: 0.5rem;
    overflow: hidden;
    box-shadow: 0 0.5rem 1.5rem rgba(26, 58, 143, 0.2);
}

/* Success/Failure States */
.import-success {
    border-left: 4px solid var(--success);
}

.import-warning {
    border-left: 4px solid var(--warning);
}

.import-danger {
    border-left: 4px solid var(--danger);
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
                <a href="Subjects.aspx" class="list-group-item list-group-item-action active">
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
            
          <!-- Page Title -->
<div class="d-flex justify-content-between align-items-center mb-4 page-header">
    <h2 class="mb-0 page-title"><i class="bi bi-journals me-2 gold-accent"></i>Manage Subjects</h2>
    <div>
        <button type="button" class="btn btn-success me-2" data-bs-toggle="modal" data-bs-target="#importModal">
            <i class="bi bi-upload me-1"></i>Import CSV
        </button>
    </div>
</div>

            <!-- Add Subject Card -->
            <div class="card mb-4">
                <div class="card-header py-3">
                    <h5 class="m-0 fw-bold text-primary"><i class="bi bi-plus-circle me-2"></i>Add New Subject</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3 align-items-end add-subject-form">
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Subject Code</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-code"></i></span>
                                <asp:TextBox ID="txtSubjectCode" runat="server" CssClass="form-control" placeholder="Subject Code"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label fw-semibold">Subject Name</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-journal-text"></i></span>
                                <asp:TextBox ID="txtSubjectName" runat="server" CssClass="form-control" placeholder="Subject Name"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <asp:Button ID="btnAddSubject" runat="server" Text="Add Subject" CssClass="btn btn-primary w-100" OnClick="btnAddSubject_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Subjects Grid -->
            <div class="card">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h5 class="m-0 fw-bold text-primary"><i class="bi bi-list-ul me-2"></i>Subjects List</h5>
                    <div class="col-md-4">
                        <div class="input-group">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search subject..." />
                            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-secondary" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvSubjects" runat="server" 
                            CssClass="table table-striped table-bordered table-hover"
                            AutoGenerateColumns="False" DataKeyNames="SubjectID"
                            AllowPaging="true" PageSize="25"
                            OnPageIndexChanging="gvSubjects_PageIndexChanging"
                            OnRowEditing="gvSubjects_RowEditing"
                            OnRowCancelingEdit="gvSubjects_RowCancelingEdit"
                            OnRowUpdating="gvSubjects_RowUpdating"
                            OnRowDeleting="gvSubjects_RowDeleting">

                            <Columns>
                                <asp:BoundField DataField="SubjectID" HeaderText="ID" ReadOnly="True" Visible="False" />

                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-code me-2 text-primary"></i> Code
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%# Eval("SubjectCode") %>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="bi bi-code"></i></span>
                                            <asp:TextBox ID="txtEditSubjectCode" runat="server" CssClass="form-control"
                                                Text='<%# Bind("SubjectCode") %>' />
                                        </div>
                                    </EditItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-journal-text me-2 text-info"></i> Subject Name
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%# Eval("SubjectName") %>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="bi bi-journal-text"></i></span>
                                            <asp:TextBox ID="txtEditSubjectName" runat="server" CssClass="form-control"
                                                Text='<%# Bind("SubjectName") %>' />
                                        </div>
                                    </EditItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <div class="action-buttons">
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-sm btn-warning">
                                                <i class="bi bi-pencil"></i> Edit
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete"
                                                CssClass="btn btn-sm btn-danger"
                                                OnClientClick="return confirm('Are you sure you want to delete this subject?');">
                                                <i class="bi bi-trash"></i> Delete
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <div class="action-buttons">
                                            <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="btn btn-sm btn-success">
                                                <i class="bi bi-check"></i> Update
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="btn btn-sm btn-secondary">
                                                <i class="bi bi-x"></i> Cancel
                                            </asp:LinkButton>
                                        </div>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            
                            <PagerStyle CssClass="pagination" />
                            <PagerSettings Mode="NumericFirstLast" />
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
<!-- Import CSV Modal -->
<div class="modal fade" id="importModal" tabindex="-1" aria-labelledby="importModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="importModalLabel">
                    <i class="bi bi-file-earmark-spreadsheet me-2"></i>Import Subjects from CSV
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- File Upload Section -->
                <div class="mb-4">
                    <label class="form-label fw-semibold">Select CSV File</label>
                    <div class="input-group">
                        <asp:FileUpload ID="fuCsvFile" runat="server" CssClass="form-control" accept=".csv" />
                        <asp:Button ID="btnDownloadTemplate" runat="server" Text="Download Template" 
                            CssClass="btn btn-outline-info" OnClick="btnDownloadTemplate_Click" />
                    </div>
                    <div class="form-text">
                        <small>CSV format: SubjectCode,SubjectName (with header row). Maximum file size: 5MB</small>
                    </div>
                </div>

                <!-- Simple Status Message -->
                <div id="importStatus" class="alert alert-info d-none">
                    <i class="bi bi-info-circle me-2"></i>
                    <span id="statusText">Processing your file...</span>
                </div>

                <!-- Import Results -->
                <div id="importResults" class="d-none">
                    <h6 class="fw-bold mb-3"><i class="bi bi-check-circle me-2"></i>Import Results</h6>
                    <div class="alert" id="resultsAlert">
                        <div class="row text-center mb-3">
                            <div class="col-md-3">
                                <div class="stat-item">
                                    <span class="stat-value stat-info" id="statTotal">0</span>
                                    <small>Total Records</small>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-item">
                                    <span class="stat-value stat-success" id="statSuccessful">0</span>
                                    <small>Successful</small>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-item">
                                    <span class="stat-value stat-warning" id="statDuplicates">0</span>
                                    <small>Duplicates</small>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-item">
                                    <span class="stat-value stat-danger" id="statFailed">0</span>
                                    <small>Failed</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Simple Failed Records Summary -->
                    <div id="failedRecordsSection" class="d-none mt-3">
                        <div class="alert alert-warning">
                            <i class="bi bi-exclamation-triangle me-2"></i>
                            <span id="failedRecordsCount">0</span> records failed to import. 
                            Check the details below for specific errors.
                        </div>
                        <div class="failed-records-list small">
                            <div id="failedRecordsList">
                                <!-- Failed records will be inserted here as simple list -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" id="closeButton">Close</button>
                <asp:Button ID="btnImportCsv" runat="server" Text="Import Subjects" 
                    CssClass="btn btn-success" OnClick="btnImportCsv_Click" />
            </div>
        </div>
    </div>
</div>
<!-- Hidden fields to store import results -->
<asp:HiddenField ID="hfImportResults" runat="server" />
<asp:HiddenField ID="hfFailedRecords" runat="server" />

    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // ========== INITIALIZATION ==========
        document.addEventListener('DOMContentLoaded', function () {
            console.log('DOM loaded - initializing subjects page');
            initializeComponents();
            setupEventListeners();
            initializeModal();
        });

        // ========== CORE INITIALIZATION ==========
        function initializeComponents() {
            initializeSidebar();
            initializeAlerts();
        }

        function setupEventListeners() {
            window.addEventListener('resize', handleResize);
        }

        // ========== SIDEBAR MANAGEMENT ==========
        function initializeSidebar() {
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
                collapseSidebar();
            }

            // Toggle sidebar on button click
            sidebarToggler.addEventListener('click', function () {
                toggleSidebar();
            });

            // Mobile sidebar toggler
            if (mobileSidebarToggler) {
                mobileSidebarToggler.addEventListener('click', function () {
                    toggleMobileSidebar();
                });
            }

            // Close mobile sidebar when clicking outside
            if (sidebarOverlay) {
                sidebarOverlay.addEventListener('click', function () {
                    closeMobileSidebar();
                });
            }
        }

        function collapseSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            const sidebarToggler = document.getElementById('sidebarToggler');

            sidebar?.classList.add('collapsed');
            mainContent?.classList.add('collapsed');
            if (sidebarToggler) {
                sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
            }
        }

        function expandSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            const sidebarToggler = document.getElementById('sidebarToggler');

            sidebar?.classList.remove('collapsed');
            mainContent?.classList.remove('collapsed');
            if (sidebarToggler) {
                sidebarToggler.innerHTML = '<i class="bi bi-arrow-left-circle"></i>';
            }
        }

        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');

            if (sidebar?.classList.contains('collapsed')) {
                expandSidebar();
                localStorage.setItem('sidebarCollapsed', 'false');
            } else {
                collapseSidebar();
                localStorage.setItem('sidebarCollapsed', 'true');
            }
        }

        function toggleMobileSidebar() {
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');

            sidebar?.classList.toggle('mobile-show');
            if (sidebarOverlay) {
                sidebarOverlay.classList.toggle('show');
            }
        }

        function closeMobileSidebar() {
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');

            sidebar?.classList.remove('mobile-show');
            if (sidebarOverlay) {
                sidebarOverlay.classList.remove('show');
            }
        }

        // ========== CSV IMPORT MODAL FUNCTIONALITY ==========
        function initializeModal() {
            const importModal = document.getElementById('importModal');

            // Setup modal show/hide events
            if (importModal) {
                importModal.addEventListener('show.bs.modal', function () {
                    resetModal();
                });

                importModal.addEventListener('hidden.bs.modal', function () {
                    resetModal();
                    // Clear the file input when modal is closed
                    const fileUpload = document.getElementById('<%= fuCsvFile.ClientID %>');
            if (fileUpload) {
                fileUpload.value = '';
            }
        });
            }

            // Check if we have import results to show (after postback)
            checkForImportResults();
        }

        function resetModal() {
            // Hide all sections
            document.getElementById('importStatus').classList.add('d-none');
            document.getElementById('importResults').classList.add('d-none');

            // Reset import button
            const importButton = document.getElementById('<%= btnImportCsv.ClientID %>');
    if (importButton) {
        importButton.disabled = false;
        importButton.innerHTML = 'Import Subjects';
    }

    // Clear hidden fields
    document.getElementById('<%= hfImportResults.ClientID %>').value = '';
    document.getElementById('<%= hfFailedRecords.ClientID %>').value = '';
}

function checkForImportResults() {
    const importResults = document.getElementById('<%= hfImportResults.ClientID %>');

    if (importResults && importResults.value) {
        try {
            const results = JSON.parse(importResults.value);
            showImportResults(results);
        } catch (e) {
            console.error('Error parsing import results:', e);
        }
    }
}

function showImportResults(results) {
    // Update statistics
    document.getElementById('statTotal').textContent = results.TotalRecords || 0;
    document.getElementById('statSuccessful').textContent = results.Successful || 0;
    document.getElementById('statDuplicates').textContent = results.Duplicates || 0;
    document.getElementById('statFailed').textContent = results.Failed || 0;

    // Update results alert style
    const resultsAlert = document.getElementById('resultsAlert');
    if (results.Successful > 0) {
        resultsAlert.className = 'alert alert-success import-success';
    } else if (results.Failed > 0) {
        resultsAlert.className = 'alert alert-danger import-danger';
    } else {
        resultsAlert.className = 'alert alert-warning import-warning';
    }

    // Show failed records if any
    const failedRecordsSection = document.getElementById('failedRecordsSection');
    const failedRecordsList = document.getElementById('failedRecordsList');
    const failedRecordsCount = document.getElementById('failedRecordsCount');
    const failedRecords = document.getElementById('<%= hfFailedRecords.ClientID %>');

    if (results.FailedRecords && results.FailedRecords.length > 0 && failedRecordsList) {
        failedRecordsList.innerHTML = failedRecords.value || '';
        failedRecordsCount.textContent = results.FailedRecords.length;
        failedRecordsSection.classList.remove('d-none');
    } else {
        failedRecordsSection.classList.add('d-none');
    }

    // Show results
    document.getElementById('importResults').classList.remove('d-none');
}

        // ========== UTILITY FUNCTIONS ==========
        function initializeAlerts() {
            const alertElement = document.getElementById('<%= lblMessage.ClientID %>');
            if (alertElement && alertElement.textContent.trim() !== '') {
                alertElement.classList.remove('d-none');

                // Auto-hide alert after 5 seconds
                setTimeout(function () {
                    alertElement.classList.add('d-none');
                }, 5000);
            }
        }

        function handleResize() {
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');

            if (window.innerWidth >= 768) {
                closeMobileSidebar();
            }
        }

        // ========== ASP.NET AJAX SUPPORT ==========
        if (typeof Sys !== 'undefined') {
            const prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                console.log('Async postback completed - reinitializing');
                initializeComponents();
                initializeModal();
            });
        }



        // Function to update sidebar badges
        function updateSidebarBadges() {
            $.ajax({
                type: "POST",
                url: "Subjects.aspx/GetSidebarBadgeCounts",
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
    </script>
</body>
</html>

