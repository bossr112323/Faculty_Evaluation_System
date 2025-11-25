<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EvaluationCycles.aspx.vb" Inherits="Faculty_Evaluation_System.EvaluationCycles" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Evaluation Cycles - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
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
        height: var(--header-height);
        z-index: 1000;
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
    
    /* Status badges */
    .status-badge {
        padding: 0.35rem 0.65rem;
        border-radius: 0.35rem;
        font-size: 0.75rem;
        font-weight: 700;
    }
    
    .status-active {
        background-color: rgba(25, 135, 84, 0.2);
        color: #198754;
    }
    
    .status-inactive {
        background-color: rgba(108, 117, 125, 0.2);
        color: #6c757d;
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
        .add-cycle-form .row {
            flex-direction: column;
        }
        
        .add-cycle-form .col-md-3,
        .add-cycle-form .col-md-2 {
            width: 100%;
            margin-bottom: 1rem;
        }
        
        .add-cycle-form .btn {
            width: 100%;
        }
        
        /* GridView action buttons */
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        
        .action-buttons .btn {
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
    
    .btn-sm {
        padding: 0.25rem 0.5rem;
        font-size: 0.875rem;
    }
    
    .action-buttons {
        white-space: nowrap;
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
    
    /* Add Cycle form styling */
    .add-cycle-form {
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
    
    /* Status badges with Golden West colors */
    .badge.bg-primary {
        background-color: var(--primary) !important;
    }
    
    /* Cycle card styling */
    .cycle-card {
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    
    .cycle-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
    }
    
    /* Empty state styling */
    .empty-state {
        background-color: #f8f9fc;
        border: 2px dashed #e3e6f0;
        border-radius: 0.35rem;
        padding: 2rem;
        text-align: center;
    }
    
    .empty-state i {
        color: var(--primary-light);
        margin-bottom: 1rem;
    }
    
    /* Date input styling */
    .form-control[type="date"] {
        position: relative;
    }
    
    .form-control[type="date"]::-webkit-calendar-picker-indicator {
        background: transparent;
        bottom: 0;
        color: transparent;
        cursor: pointer;
        height: auto;
        left: 0;
        position: absolute;
        right: 0;
        top: 0;
        width: auto;
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
                        <asp:Label ID="lblWelcome" runat="server" />
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
                <a href="EvaluationCycles.aspx" class="list-group-item list-group-item-action active">
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
                <h2 class="mb-0 page-title"><i class="bi bi-arrow-repeat me-2 gold-accent"></i>Manage Evaluation Cycles</h2>
                <span class="badge bg-primary fs-6">
                    <asp:Label ID="lblCycleCount" runat="server" Text="0" /> cycle(s)
                </span>
            </div>

            <!-- Add Cycle Card -->
            <div class="card mb-4">
                <div class="card-header py-3">
                    <h5 class="m-0 fw-bold text-primary"><i class="bi bi-plus-circle me-2"></i>Create New Cycle</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3 align-items-end add-cycle-form">
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Term</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-calendar-event"></i></span>
                                <asp:DropDownList ID="ddlTerm" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select Term" Value="" Selected="True" />
                                    <asp:ListItem Text="1st Semester" Value="1st Semester" />
                                    <asp:ListItem Text="2nd Semester" Value="2nd Semester" />
                                 
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Cycle Name</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-tag"></i></span>
                                <asp:TextBox ID="txtCycleName" runat="server" CssClass="form-control" placeholder="e.g. Midterm Evaluation" MaxLength="100"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-semibold">Start Date</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-calendar-check"></i></span>
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-semibold">End Date</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-calendar-x"></i></span>
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <asp:Button ID="btnAddCycle" runat="server" Text="Add Cycle" CssClass="btn btn-primary w-100" OnClick="btnAddCycle_Click" />
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Cycles Grid -->
            <div class="card">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h5 class="m-0 fw-bold text-primary"><i class="bi bi-list-ul me-2"></i>Evaluation Cycles</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvCycles" runat="server" CssClass="table table-striped table-bordered table-hover"
                            AutoGenerateColumns="False" DataKeyNames="CycleID"
                            OnRowCommand="gvCycles_RowCommand" OnRowDataBound="gvCycles_RowDataBound"
                            OnRowDeleting="gvCycles_RowDeleting" 
                            EmptyDataText="No evaluation cycles found.">
                            <Columns>
                                <asp:BoundField DataField="CycleID" HeaderText="ID" ReadOnly="True" Visible="False" />
                                
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-calendar-event me-2 text-primary"></i>Term
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <strong><%# HttpUtility.HtmlEncode(Eval("Term").ToString()) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-tag me-2 text-info"></i>Cycle Name
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%# HttpUtility.HtmlEncode(Eval("CycleName").ToString()) %>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-calendar-check me-2 text-success"></i>Start Date
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%# Format(Eval("StartDate"), "MMM dd, yyyy") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                

                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-calendar-x me-2 text-danger"></i>End Date
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%# Format(Eval("EndDate"), "MMM dd, yyyy") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                

                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-circle-fill me-2 text-secondary"></i>Status
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <span class='status-badge <%# If(Eval("Status").ToString() = "Active", "status-active", "status-inactive") %>'>
                                            <i class='<%# If(Eval("Status").ToString() = "Active", "bi bi-check-circle", "bi bi-circle") %> me-1'></i>
                                            <%# Eval("Status") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <i class="bi bi-gear me-2 text-secondary"></i>Actions
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <div class="action-buttons">
                                            <asp:LinkButton ID="btnActivate" runat="server" CommandName="Activate"
                                                CommandArgument='<%# Eval("CycleID") %>' CssClass="btn btn-success btn-sm"
                                                Visible='<%# Eval("Status").ToString() <> "Active" %>'
                                                ToolTip="Activate this cycle">
                                                <i class="bi bi-play-circle"></i> Activate
                                            </asp:LinkButton>
                                            
                                            <asp:LinkButton ID="btnDeactivate" runat="server" CommandName="Deactivate"
                                                CommandArgument='<%# Eval("CycleID") %>' CssClass="btn btn-warning btn-sm"
                                                Visible='<%# Eval("Status").ToString() = "Active" %>'
                                                ToolTip="Deactivate this cycle">
                                                <i class="bi bi-pause-circle"></i> Deactivate
                                            </asp:LinkButton>
                                            
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteCycle"
                                                CommandArgument='<%# Eval("CycleID") %>' CssClass="btn btn-danger btn-sm"
                                                Visible='<%# Eval("Status").ToString() <> "Active" %>'
                                                ToolTip="Delete this cycle">
                                                <i class="bi bi-trash"></i> Delete
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            
                            <EmptyDataTemplate>
                                <div class="text-center py-4">
                                    <i class="bi bi-arrow-repeat display-4 text-muted"></i>
                                    <p class="mt-3 text-muted">No evaluation cycles found. Create your first cycle above.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
       
     // Toggle sidebar
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            const sidebarToggler = document.getElementById('sidebarToggler');
            const mobileSidebarToggler = document.getElementById('mobileSidebarToggler');

            // Check if we have a saved state in localStorage
            const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';

            // Apply saved state on page load
            if (isCollapsed) {
                sidebar.classList.add('collapsed');
            mainContent.classList.add('collapsed');
            sidebarToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
     }

            // Toggle sidebar on button click
            sidebarToggler.addEventListener('click', function() {
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
            mobileSidebarToggler.addEventListener('click', function() {
                sidebar.classList.toggle('mobile-show');
     });

            // Close sidebar when clicking outside on mobile
            document.addEventListener('click', function(event) {
         if (window.innerWidth < 768 &&
            !sidebar.contains(event.target) &&
            !mobileSidebarToggler.contains(event.target) &&
            sidebar.classList.contains('mobile-show')) {
                sidebar.classList.remove('mobile-show');
         }
     });

            // Handle alert messages
            const alertElement = document.getElementById('<%= lblMessage.ClientID %>');
            if (alertElement && alertElement.textContent.trim() !== '') {
                alertElement.classList.remove('d-none');

            // Auto-hide alert after 5 seconds
            setTimeout(function() {
                alertElement.classList.add('d-none');
         }, 5000);
     }

            // Date validation
            document.addEventListener('DOMContentLoaded', function() {
         const startDate = document.getElementById('<%= txtStartDate.ClientID %>');
         const endDate = document.getElementById('<%= txtEndDate.ClientID %>');

            if (startDate && endDate) {
             // Set minimum dates to today
             const today = new Date().toISOString().split('T')[0];
            startDate.min = today;
            endDate.min = today;

            startDate.addEventListener('change', function () {
                 if (endDate.value && new Date(startDate.value) > new Date(endDate.value)) {
                alert('Start date cannot be after end date.');
            startDate.value = '';
                 }
             });

            endDate.addEventListener('change', function () {
                 if (startDate.value && new Date(endDate.value) < new Date(startDate.value)) {
                alert('End date cannot be before start date.');
            endDate.value = '';
                 }
             });
         }
            });


            // Adjust sidebar on resize
            window.addEventListener('resize', function () {
         if (window.innerWidth >= 768) {
                sidebar.classList.remove('mobile-show');
         }
            });

        // Function to update sidebar badges
        function updateSidebarBadges() {
            $.ajax({
                type: "POST",
                url: "EvaluationCycles.aspx/GetSidebarBadgeCounts",
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