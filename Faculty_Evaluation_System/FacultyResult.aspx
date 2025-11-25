<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="FacultyResult.aspx.vb" Inherits="Faculty_Evaluation_System.FacultyResult" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Evaluation Results - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        
        /* Header styling with Golden West color scheme */
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
        
        .stat-card {
            border-left: 4px solid;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
        }
        
        .stat-card.overall {
            border-left-color: var(--primary);
        }
        
        .stat-card.subjects {
            border-left-color: var(--info);
        }
        
        .stat-card.trend {
            border-left-color: var(--warning);
        }
        
        .stat-card.response {
            border-left-color: var(--success);
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
        
        /* Filter Section Styling */
        .filter-section {
            background: white;
            margin: 0.5rem;
            border-radius: 8px;
            padding: 1rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .filter-section .sidebar-header {
            color: var(--primary);
            padding: 0 0 0.75rem 0;
            margin-bottom: 1rem;
            border-bottom: 1px solid #e3e6f0;
        }
        
        .filter-section .form-label {
            color: var(--dark);
            font-weight: 600;
            font-size: 0.85rem;
        }
        
        .filter-section .form-control {
            border: 1px solid #d1d3e2;
            border-radius: 6px;
            font-size: 0.9rem;
        }
        
        .filter-section .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.1);
        }
        
        .filter-section .input-group-text {
            background-color: #f8f9fc;
            border: 1px solid #d1d3e2;
            color: var(--primary);
        }

        .refresh-btn {
            cursor: pointer;
            transition: transform 0.3s ease;
        }
        
        .refresh-btn:hover {
            transform: rotate(180deg);
        }
        
        .loading-spinner {
            display: none;
            width: 1rem;
            height: 1rem;
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
        
        /* Golden West specific styling */
        .dashboard-title {
            color: var(--primary);
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.5rem;
        }
        
        .gold-accent {
            color: var(--gold);
        }

        /* Improved Autocomplete Styling */
       .ui-autocomplete {
    max-height: 300px;
    overflow-y: auto;
    overflow-x: hidden;
    background: white;
    border: 1px solid var(--primary);
    border-radius: 8px;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
    z-index: 1001;
    position: fixed !important; /* Changed to fixed positioning */
    width: 240px !important; /* Fixed width to match sidebar */
    left: auto !important; /* Reset left positioning */
    right: auto !important; /* Reset right positioning */
}

        .ui-autocomplete .ui-menu-item {
    padding: 0;
    border-bottom: 1px solid #e3e6f0;
    transition: all 0.2s ease;
}


        .ui-autocomplete .ui-menu-item:last-child {
            border-bottom: none;
        }

        .ui-autocomplete .ui-menu-item-wrapper {
    padding: 12px 16px;
    display: block;
    color: var(--dark);
    text-decoration: none;
    transition: all 0.2s ease;
    border: none;
    border-radius: 0;
    font-size: 0.9rem;
}

       .ui-autocomplete .ui-menu-item-wrapper:hover,
.ui-autocomplete .ui-menu-item-wrapper.ui-state-active {
    background: rgba(26, 58, 143, 0.08);
    color: var(--primary);
    border: none;
    margin: 0;
}

.autocomplete-item {
    cursor: pointer;
}

.autocomplete-item .fw-bold {
    font-size: 0.9rem;
    margin-bottom: 4px;
    color: var(--primary);
}

.autocomplete-item .small {
    font-size: 0.75rem;
    line-height: 1.3;
    color: var(--secondary);
}

.autocomplete-item .badge {
    font-size: 0.65rem;
    padding: 2px 6px;
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
            
            .stat-card .h5 {
                font-size: 1.25rem;
            }
            
            .content .d-flex.justify-content-between h3 {
                font-size: 1.5rem;
            }
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

        /* Subject list styling */
        .subject-list {
            max-height: 400px;
            overflow-y: auto;
            padding: 0 0.5rem;
        }

        .subject-item {
            background: white;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 0.75rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-left: 4px solid var(--primary);
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .subject-item:hover {
            transform: translateX(4px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .subject-item.active {
            border-left-color: var(--gold);
            background: rgba(26, 58, 143, 0.05);
        }

        .subject-name {
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.25rem;
            font-size: 0.9rem;
        }

        .subject-code {
            font-size: 0.8rem;
            color: var(--secondary);
        }

        .subject-score {
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--primary);
        }

        /* Rating badges */
        .rating-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .badge-excellent { background: rgba(40, 167, 69, 0.15); color: var(--success); }
        .badge-good { background: rgba(255, 193, 7, 0.15); color: #856404; }
        .badge-average { background: rgba(253, 126, 20, 0.15); color: #fd7e14; }
        .badge-poor { background: rgba(220, 53, 69, 0.15); color: var(--danger); }

        /* Progress bars */
        .progress {
            height: 8px;
            border-radius: 4px;
        }

        /* Loading spinner */
        .loading-spinner-full {
            display: inline-block;
            width: 2rem;
            height: 2rem;
            border: 3px solid #f3f3f3;
            border-top: 3px solid var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: var(--secondary);
        }

        /* Chart containers */
        .chart-container {
            height: 300px;
            position: relative;
        }

        /* Question items */
        .question-item {
            padding: 1rem 0;
            border-bottom: 1px solid #e3e6f0;
        }

        .question-item:last-child {
            border-bottom: none;
        }

        .domain-title {
            font-weight: 600;
            color: var(--primary);
            margin: 1.5rem 0 0.75rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #e3e6f0;
        }

        /* Comment items */
        .comment-item {
            padding: 1rem;
            border-radius: 8px;
            background: #f8f9fa;
            margin-bottom: 1rem;
        }

        .comment-text {
            font-size: 0.9rem;
            line-height: 1.5;
        }
        /* Comment Group Styles - From First Code */
.comment-group .card {
    border: 1px solid #dee2e6;
}

.comment-group .card-header {
    border-bottom: 1px solid rgba(255,255,255,0.1);
    font-weight: 600;
}

.comment-item {
    border: none;
    border-bottom: 1px solid #f8f9fa;
    padding: 0.75rem;
    transition: background-color 0.2s ease;
}

.comment-item:last-child {
    border-bottom: none;
}

.comment-item:hover {
    background-color: #f8f9fa;
}

.comment-text {
    font-size: 0.85rem;
    line-height: 1.4;
    color: #495057;
}

.list-group-flush .list-group-item {
    border-radius: 0;
}

.comment-group:last-child {
    margin-bottom: 0 !important;
}

/* Question Breakdown Styles - From First Code */
.question-group {
    margin-bottom: 1.5rem;
}

.domain-header {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
    color: white;
    padding: 0.75rem 1rem;
    border-radius: 6px 6px 0 0;
    font-weight: 600;
    margin-bottom: 0;
}

.question-item {
    padding: 1rem;
    border-bottom: 1px solid #e3e6f0;
    background: white;
}

.question-item:last-child {
    border-bottom: none;
}

.question-text {
    font-size: 0.9rem;
    line-height: 1.4;
    margin-bottom: 0.5rem;
}

.question-score {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 0.85rem;
}

.score-value {
    font-weight: 700;
    color: var(--primary);
}

/* Ensure proper spacing for comment groups */
.comment-group {
    margin-bottom: 1rem;
}

.comment-group:last-child {
    margin-bottom: 0;
}
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
        <asp:HiddenField ID="hdnCycleID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedLoadID" runat="server" Value="0" />
        <asp:HiddenField ID="hdnSelectedCycleID" runat="server" Value="0" />
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
                <small class="text-white-50">Faculty Evaluation System (Faculty Dashbooard)</small>
            </div>
        </div>
    </div>
    <div class="d-flex align-items-center">
        <!-- Department Info -->
        <span class="text-white d-none d-md-block me-3">
            <i class="bi bi-building-gear me-1"></i>
            <asp:Label ID="lblDepartment" runat="server" CssClass="fw-bold"></asp:Label>
        </span>
        <!-- User Menu -->
        <div class="dropdown">
            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false">
                <i class="bi bi-person-circle me-1"></i>
                <span class="d-none d-sm-inline"><asp:Label ID="lblFacultyName" runat="server" Text="Faculty" /></span>
            </button>
            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
                <li><a class="dropdown-item" href="ChangePassword.aspx"><i class="bi bi-key me-2"></i>Change Password</a></li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <asp:LinkButton ID="btnLogout" runat="server" CssClass="dropdown-item text-danger" OnClick="btnLogout_Click">
                        <i class="bi bi-box-arrow-right me-2"></i>Logout
                    </asp:LinkButton>
                </li>
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
                <a href="FacultyDashboard.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-speedometer2"></i>
                    <span class="list-group-text">Dashboard Overview</span>
                </a>
                <a href="GradeSubmission.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-cloud-upload"></i>
                    <span class="list-group-text">Submit Grades</span>
                </a>
                <a href="FacultyResult.aspx" class="list-group-item list-group-item-action active">
                    <i class="bi bi-graph-up"></i>
                    <span class="list-group-text">Evaluation Results</span>
                </a>
            </div>

            <!-- Filter Section -->
          <div class="filter-section">
    <h6 class="sidebar-header">Filter Results</h6>
    
    <div class="mb-3">
        <label class="form-label fw-semibold small">Evaluation Cycle</label>
        <asp:TextBox ID="txtCycle" runat="server" CssClass="form-control" 
            placeholder="Search cycles..."></asp:TextBox>
    </div>
    
    <div class="mb-3">
        <label class="form-label fw-semibold small">Search Subjects</label>
        <asp:TextBox ID="txtSubjectSearch" runat="server" CssClass="form-control" 
            placeholder="Subject name or code..."></asp:TextBox>
    </div>
    
    <div class="d-grid gap-2">
        <asp:Button ID="btnFilter" runat="server" Text="Apply Filters" CssClass="btn btn-primary" OnClick="btnFilter_Click" />
       
    </div>
</div>

            <!-- Subject List -->
            <div class="filter-section">
                <h6 class="sidebar-header">My Subjects</h6>
                <div id="subjectList" runat="server" class="subject-list">
                    <!-- Subject items will be populated here -->
                </div>
            </div>
            
            <button id="sidebarToggler" class="sidebar-toggler d-none d-lg-block">
                <i class="bi bi-arrow-left-circle"></i>
            </button>
        </div>

        <!-- Main Content -->
        <div class="content" id="mainContent">
            <!-- Alert Container -->
            <div id="alertContainer">
                <asp:Label ID="lblAlert" runat="server" CssClass="alert d-none alert-slide" />
            </div>

            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="dashboard-title"><i class="bi bi-graph-up me-2 gold-accent"></i>Evaluation Results</h3>
                <button id="btnRefresh" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-clockwise me-1"></i>
                    <span class="d-none d-sm-inline">Refresh</span>
                    <span class="loading-spinner spinner-border spinner-border-sm ms-1"></span>
                </button>
            </div>

            <!-- Overview Section -->
            <div id="overviewSection">
                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card stat-card overall h-100">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs fw-bold text-primary text-uppercase mb-1">Overall Score</div>
                                        <div class="h5 mb-0 fw-bold text-gray-800" id="overallScore">0%</div>
                                        <div class="text-xs text-muted">Current evaluation period</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="bi bi-star-fill fa-2x text-primary"></i>
                                    </div>
                                </div>
                                <div class="mt-2" id="overviewStars"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card stat-card subjects h-100">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs fw-bold text-info text-uppercase mb-1">Subjects Evaluated</div>
                                        <div class="h5 mb-0 fw-bold text-gray-800">
                                            <span id="subjectsEvaluated">0</span>/<span id="totalSubjects">0</span>
                                        </div>
                                        <div class="text-xs text-muted">Completion rate</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="bi bi-journal-check fa-2x text-info"></i>
                                    </div>
                                </div>
                                <div class="progress mt-2" style="height: 6px;">
                                    <div id="evalProgress" class="progress-bar bg-info" style="width: 0%"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card stat-card trend h-100">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs fw-bold text-warning text-uppercase mb-1">Performance Trend</div>
                                        <div class="h5 mb-0 fw-bold text-gray-800" id="trendValue">0%</div>
                                        <div class="text-xs text-muted">vs previous cycle</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="bi" id="trendIcon"></i>
                                    </div>
                                </div>
                                <div class="stat-trend mt-2" id="trendIndicator">
                                    <span id="trendText">No change</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card stat-card response h-100">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs fw-bold text-success text-uppercase mb-1">Response Rate</div>
                                        <div class="h5 mb-0 fw-bold text-gray-800" id="responseRate">0%</div>
                                        <div class="text-xs text-muted">Student participation</div>
                                    </div>
                                    <div class="col-auto">
                                        <i class="bi bi-people-fill fa-2x text-success"></i>
                                    </div>
                                </div>
                                <div class="progress mt-2" style="height: 6px;">
                                    <div id="responseProgress" class="progress-bar bg-success" style="width: 0%"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Domain Performance Chart -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0 text-primary">
                            <i class="bi bi-bar-chart me-2"></i>Domain Performance
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="overviewChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Subject Details Section -->
            <div id="subjectSection" style="display: none;">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h4 class="text-primary mb-1" id="subjectTitle">Subject Details</h4>
                        <p class="text-muted mb-0" id="subjectDetailsText"></p>
                    </div>
                    <div class="text-end">
                        <div class="h2 text-primary mb-1" id="subjectScore">0%</div>
                        <div class="rating-badge" id="subjectRating">No Rating</div>
                    </div>
                </div>
                
                <!-- Domain Breakdown -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0 text-primary">
                            <i class="bi bi-bar-chart me-2"></i>Domain Scores
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="domainChart"></canvas>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-lg-8">
                        <!-- Question Breakdown -->
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0 text-primary">
                                    <i class="bi bi-question-circle me-2"></i>Question Breakdown
                                </h5>
                            </div>
                            <div class="card-body">
                                <div id="questionList"></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <!-- Student Feedback -->
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0 text-primary">
                                    <i class="bi bi-chat-text me-2"></i>Student Feedback
                                </h5>
                                <span class="badge bg-primary" id="commentsCount">0</span>
                            </div>
                            <div class="card-body">
                                <div id="commentsList"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script>
        // Faculty Results Module
        const FacultyResults = (function () {
            let overviewChart = null;
            let domainChart = null;
            let currentData = {
                overview: null,
                status: null,
                subjectDetails: null
            };

            // Initialize the application
            function initialize() {
                setupEventHandlers();
                initializeAutocompletes();
                loadInitialData();
                restoreUIState();
            }

            function setupEventHandlers() {
                // Sidebar toggle functionality
                const sidebar = document.getElementById('sidebar');
                const mainContent = document.getElementById('mainContent');
                const sidebarToggler = document.getElementById('sidebarToggler');
                const mobileSidebarToggler = document.getElementById('mobileSidebarToggler');
                const sidebarOverlay = document.getElementById('sidebarOverlay');

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
                mobileSidebarToggler.addEventListener('click', function () {
                    sidebar.classList.toggle('mobile-show');
                    sidebarOverlay.classList.toggle('show');
                });

                // Close sidebar when clicking outside on mobile
                sidebarOverlay.addEventListener('click', function () {
                    sidebar.classList.remove('mobile-show');
                    sidebarOverlay.classList.remove('show');
                });

                // Handle alert messages
                const alertElement = document.getElementById('<%= lblAlert.ClientID %>');
                if (alertElement && alertElement.textContent.trim() !== '') {
                    alertElement.classList.remove('d-none');
                    setTimeout(function () {
                        alertElement.classList.add('d-none');
                    }, 5000);
                }

                // Adjust sidebar on resize
                window.addEventListener('resize', function () {
                    if (window.innerWidth >= 768) {
                        sidebar.classList.remove('mobile-show');
                        sidebarOverlay.classList.remove('show');
                    }
                });

                // Refresh button functionality
                document.getElementById('btnRefresh').addEventListener('click', function () {
                    const btn = this;
                    const spinner = btn.querySelector('.loading-spinner');
                    const icon = btn.querySelector('.bi-arrow-clockwise');

                    // Show loading state
                    icon.style.display = 'none';
                    spinner.style.display = 'inline-block';
                    btn.disabled = true;

                    refreshData().finally(() => {
                        icon.style.display = 'inline-block';
                        spinner.style.display = 'none';
                        btn.disabled = false;
                    });
                });
            }

            function initializeAutocompletes() {
                // Initialize cycle autocomplete with improved positioning
                $('#<%= txtCycle.ClientID %>').autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: '<%= ResolveUrl("~/FacultyResult.aspx/GetCyclesWithDates") %>',
                data: JSON.stringify({ searchText: request.term }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    const items = data?.d?.map(item => ({
                        label: item.Name,
                        value: item.Name,
                        id: item.ID,
                        term: item.TermName,
                        cycleName: item.CycleName,
                        startDate: item.StartDate,
                        endDate: item.EndDate,
                        isLatest: item.IsLatest || false
                    })) || [];
                    response(items);
                },
                error: (xhr, status, error) => {
                    console.error('Cycle autocomplete error:', error);
                    response([]);
                }
            });
        },
        minLength: 1,
        delay: 300,
        position: {
            my: "left top",
            at: "left bottom",
            collision: "none",
            using: function (position, feedback) {
                $(this).css(position);
                // Ensure autocomplete stays within sidebar bounds
                const sidebar = document.getElementById('sidebar');
                const sidebarRect = sidebar.getBoundingClientRect();
                const autocomplete = $(this);

                autocomplete.css({
                    'width': '240px',
                    'max-width': '240px',
                    'left': sidebarRect.left + 'px !important',
                    'top': (feedback.element.offset().top + feedback.element.outerHeight()) + 'px'
                });
            }
        },
        select: function (event, ui) {
            handleCycleSelection(ui.item);
            return false;
        }
    }).autocomplete("instance")._renderItem = function (ul, item) {
        const dateRange = formatDisplayDate(item.startDate) + ' to ' + formatDisplayDate(item.endDate);
        return $("<li>").append(`
            <div class="autocomplete-item p-2">
                <div class="fw-bold">${escapeHtml(item.label)}</div>
                <div class="small text-muted">
                    ${escapeHtml(item.term)} • ${dateRange}
                    ${item.isLatest ? '<span class="badge bg-success ms-1">Latest</span>' : ''}
                </div>
            </div>
        `).appendTo(ul);
    };

                // Initialize subject autocomplete with improved positioning
                $('#<%= txtSubjectSearch.ClientID %>').autocomplete({
        source: function (request, response) {
            const cycleID = $('#<%= hdnCycleID.ClientID %>').val() || 0;
            const facultyID = <%= Session("UserID") %>;

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("~/FacultyResult.aspx/GetSubjectsForAutoComplete") %>',
                data: JSON.stringify({
                    facultyID: facultyID,
                    searchText: request.term,
                    cycleID: parseInt(cycleID) || 0
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    const items = data?.d?.map(item => ({
                        label: item.Name + " (" + item.Code + ")",
                        value: item.Name,
                        id: item.ID,
                        code: item.Code,
                        term: item.Term,
                        cycleName: item.CycleName
                    })) || [];
                    response(items);
                },
                error: (xhr, status, error) => {
                    console.error('Subject autocomplete error:', error);
                    response([]);
                }
            });
        },
        minLength: 1,
        delay: 300,
        position: {
            my: "left top",
            at: "left bottom",
            collision: "none",
            using: function (position, feedback) {
                $(this).css(position);
                // Ensure autocomplete stays within sidebar bounds
                const sidebar = document.getElementById('sidebar');
                const sidebarRect = sidebar.getBoundingClientRect();
                const autocomplete = $(this);

                autocomplete.css({
                    'width': '240px',
                    'max-width': '240px',
                    'left': sidebarRect.left + 'px !important',
                    'top': (feedback.element.offset().top + feedback.element.outerHeight()) + 'px'
                });
            }
        },
        select: function (event, ui) {
            handleSubjectSelection(ui.item);
            return false;
        }
    }).autocomplete("instance")._renderItem = function (ul, item) {
        return $("<li>").append(`
            <div class="autocomplete-item p-2">
                <div class="fw-bold">${escapeHtml(item.value)}</div>
                <div class="small text-muted">
                    ${escapeHtml(item.code)} • ${escapeHtml(item.term)}${item.cycleName ? ' • ' + escapeHtml(item.cycleName) : ''}
                </div>
            </div>
        `).appendTo(ul);
    };
            }

            function handleCycleSelection(cycle) {
                $('#<%= txtCycle.ClientID %>').val(cycle.label);
                $('#<%= hdnCycleID.ClientID %>').val(cycle.id);

                // Save selection
                localStorage.setItem('selectedCycle', JSON.stringify(cycle));

                // Trigger filter after a short delay
                setTimeout(() => $('#<%= btnFilter.ClientID %>').click(), 100);
            }

            function handleSubjectSelection(subject) {
                $('#<%= txtSubjectSearch.ClientID %>').val(subject.value);
                setTimeout(() => $('#<%= btnFilter.ClientID %>').click(), 100);
            }

            function loadInitialData() {
                loadFacultyOverview();
                loadEvaluationStatus();
            }

            function restoreUIState() {
                // Restore selected cycle
                const savedCycle = localStorage.getItem('selectedCycle');
                if (savedCycle) {
                    try {
                        const cycle = JSON.parse(savedCycle);
                        $('#<%= txtCycle.ClientID %>').val(cycle.label);
                        $('#<%= hdnCycleID.ClientID %>').val(cycle.id);
                    } catch (e) {
                        console.error('Error restoring cycle:', e);
                    }
                }
            }

            async function loadEvaluationStatus() {
                const cycleID = $('#<%= hdnCycleID.ClientID %>').val() || 0;
                if (cycleID == 0) {
                    resetEvaluationStatus();
                    return;
                }
                
                try {
                    const response = await callPageMethod('GetEvaluationStatus', [
                        <%= Session("UserID") %>, 
                        cycleID
                    ]);
                    
                    if (response) {
                        currentData.status = response;
                        updateEvaluationStatusUI(response);
                    }
                } catch (error) {
                    console.error('Error loading evaluation status:', error);
                    showAlert('Error loading evaluation status', 'error');
                }
            }

            async function loadFacultyOverview() {
                const cycleID = $('#<%= hdnCycleID.ClientID %>').val() || 0;
                if (cycleID == 0) {
                    resetFacultyOverview();
                    return;
                }
                
                try {
                    const response = await callPageMethod('GetFacultyOverview', [
                        <%= Session("UserID") %>, 
                        cycleID
                    ]);
                    
                    if (response) {
                        currentData.overview = response;
                        updateFacultyOverviewUI(response);
                    }
                } catch (error) {
                    console.error('Error loading faculty overview:', error);
                    showAlert('Error loading faculty overview', 'error');
                }
            }

            function resetEvaluationStatus() {
                $('#subjectsEvaluated').text('0');
                $('#totalSubjects').text('0');
                $('#evalProgress').css('width', '0%');
                $('#overallScore').text('0%');
                $('#trendValue').text('0%');
                $('#responseRate').text('0%');
                $('#responseProgress').css('width', '0%');
                $('#trendIcon').attr('class', 'bi bi-dash-lg text-muted');
                $('#trendLabel').text('No Data');
                $('#trendText').text('No change');
                $('#overviewStars').html('');
            }

            function updateEvaluationStatusUI(status) {
                $('#subjectsEvaluated').text(status.SubjectsEvaluated || 0);
                $('#totalSubjects').text(status.TotalSubjects || 0);

                const progress = status.TotalSubjects > 0 ? 
                    ((status.SubjectsEvaluated || 0) / status.TotalSubjects) * 100 : 0;
                $('#evalProgress').css('width', progress + '%');

                $('#overallScore').text((status.CurrentCycleScore || 0).toFixed(1) + '%');
                updateTrendDisplay(status.Trend || 0);
                updateStars(status.CurrentCycleScore || 0, '#overviewStars');

                // Response rate - fixed calculation
                const responseRate = status.ResponseRate || 0;
                $('#responseRate').text(responseRate.toFixed(1) + '%');
                $('#responseProgress').css('width', responseRate + '%');
            }

            function updateTrendDisplay(trendValue) {
                let trendIcon, trendText, trendClass;

                if (trendValue > 0) {
                    trendIcon = 'bi-arrow-up-right text-success fa-2x';
                    trendText = '+' + trendValue.toFixed(1) + '% improvement';
                    trendClass = 'text-success';
                } else if (trendValue < 0) {
                    trendIcon = 'bi-arrow-down-right text-danger fa-2x';
                    trendText = Math.abs(trendValue).toFixed(1) + '% decline';
                    trendClass = 'text-danger';
                } else {
                    trendIcon = 'bi-dash-lg text-muted fa-2x';
                    trendText = 'No change';
                    trendClass = 'text-muted';
                }

                $('#trendIcon').attr('class', 'bi ' + trendIcon);
                $('#trendText').text(trendText).attr('class', 'small ' + trendClass);
                $('#trendValue').text((trendValue > 0 ? '+' : '') + trendValue.toFixed(1) + '%');
            }

            function resetFacultyOverview() {
                $('#overallScore').text('0%');
                $('#overviewStars').html('');
                if (overviewChart) {
                    overviewChart.destroy();
                    overviewChart = null;
                }
            }

            function updateFacultyOverviewUI(overview) {
                $('#overallScore').text((overview.OverallScore || 0).toFixed(1) + '%');
                updateStars(overview.OverallScore || 0, '#overviewStars');
                
                if (overviewChart) {
                    overviewChart.destroy();
                }
                
                if (overview.Domains?.length > 0) {
                    overviewChart = createBarChart('overviewChart', overview.Domains, 'Domain Performance');
                }
            }

            async function loadSubjectDetails(loadIDs, cycleID, subjectName, subjectCode, term, overallScore, cycleName, classCount) {
                showLoadingState('#subjectSection');
                updateSubjectHeader(subjectName, subjectCode, term, cycleName, overallScore, classCount);
                
                try {
                    const response = await callPageMethod('GetSubjectDetails', [loadIDs, cycleID]);
                    
                    hideLoadingState('#subjectSection');
                    if (response) {
                        currentData.subjectDetails = response;
                        updateSubjectDetailsUI(response);
                    }
                } catch (error) {
                    console.error('Error loading subject details:', error);
                    hideLoadingState('#subjectSection');
                    showAlert('Error loading subject details', 'error');
                }
            }

            function showLoadingState(selector) {
                $(selector).addClass('loading');
            }

            function hideLoadingState(selector) {
                $(selector).removeClass('loading');
            }

            function updateSubjectHeader(subjectName, subjectCode, term, cycleName, overallScore, classCount) {
                const classInfo = classCount > 1 ? ` (Combined from ${classCount} classes)` : '';
                $('#subjectTitle').text(subjectName + classInfo);
                $('#subjectDetailsText').text(`${subjectCode} • ${term}${cycleName ? ' • ' + cycleName : ''}`);
                $('#subjectScore').text((overallScore || 0).toFixed(1) + '%');
                updateRatingBadge(overallScore || 0, '#subjectRating');
            }

            function updateSubjectDetailsUI(details) {
                if (details.Questions) {
                    updateQuestionBreakdown(details.Questions);
                }
                if (details.Comments) {
                    updateComments(details.Comments);
                }
                
                if (domainChart) {
                    domainChart.destroy();
                }
                
                if (details.Domains?.length > 0) {
                    domainChart = createBarChart('domainChart', details.Domains, 'Domain Performance');
                }
            }

            function updateQuestionBreakdown(questions) {
                let html = '';
                let currentDomain = '';

                if (questions && questions.length > 0) {
                    questions.forEach(question => {
                        if (question.DomainName !== currentDomain) {
                            if (currentDomain !== '') {
                                html += '</div></div>'; // Close previous domain group
                            }

                            html += `
                    <div class="question-group mb-4">
                        <div class="domain-header">
                            <i class="bi bi-collection me-2"></i>${escapeHtml(question.DomainName)}
                        </div>
                        <div class="card">
                            <div class="card-body p-0">
                `;

                            currentDomain = question.DomainName;
                        }

                        html += `
                <div class="question-item">
                    <div class="question-text">${escapeHtml(question.QuestionText)}</div>
                    <div class="question-score">
                        <span class="text-muted">Average Score:</span>
                        <span class="score-value">${(question.AverageScore || 0).toFixed(1)}/5</span>
                    </div>
                </div>
            `;
                    });

                    if (currentDomain !== '') {
                        html += '</div></div></div>'; // Close last domain group
                    }
                } else {
                    html = `
            <div class="text-center text-muted py-4">
                <i class="bi bi-question-circle display-4"></i>
                <div class="mt-2">No question data available</div>
                <div class="small">Evaluation data for this subject is not available yet</div>
            </div>
        `;
                }

                $('#questionList').html(html);
            }

            function updateComments(commentGroups) {
                let html = '';
                let totalComments = 0;

                if (commentGroups && commentGroups.length > 0) {
                    totalComments = commentGroups.reduce((total, group) => total + (group.TotalCount || group.Comments.length), 0);
                    $('#commentsCount').text(totalComments + ' comments');

                    commentGroups.forEach(group => {
                        const groupTitle = group.CommentType;
                        const groupCount = group.TotalCount || group.Comments.length;
                        const groupIcon = getCommentGroupIcon(groupTitle);
                        const groupColor = getCommentGroupColor(groupTitle);

                        html += `
                <div class="comment-group mb-3">
                    <div class="card border-${groupColor}">
                        <div class="card-header bg-${groupColor} text-white d-flex justify-content-between align-items-center py-2">
                            <h6 class="mb-0 small">
                                <i class="bi ${groupIcon} me-1"></i>${groupTitle}
                            </h6>
                            <span class="badge bg-light text-dark small">${groupCount}</span>
                        </div>
                        <div class="card-body p-0">
                            <div class="list-group list-group-flush">`;

                        if (group.Comments && group.Comments.length > 0) {
                            group.Comments.forEach((comment, index) => {
                                html += `
                                <div class="list-group-item comment-item border-0">
                                    <div class="comment-text">
                                        <p class="mb-0 small">${escapeHtml(comment.CommentText)}</p>
                                    </div>
                                </div>`;
                            });
                        } else {
                            html += `<div class="list-group-item border-0"><p class="text-muted text-center mb-0 small">No ${groupTitle.toLowerCase()} comments</p></div>`;
                        }

                        html += `
                            </div>
                        </div>
                    </div>
                </div>`;
                    });
                } else {
                    $('#commentsCount').text('0 comments');
                    html = `
            <div class="text-center text-muted py-4">
                <i class="bi bi-chat-square-text display-4"></i>
                <div class="mt-2 small">No comments available for this subject</div>
            </div>
        `;
                }

                $('#commentsList').html(html);
            }

            // Helper functions for comment groups (add these to your JavaScript)
            function getCommentGroupIcon(commentType) {
                switch (commentType) {
                    case 'Strengths': return 'bi-check-circle-fill';
                    case 'Weaknesses': return 'bi-exclamation-triangle-fill';
                    case 'Additional Comments': return 'bi-chat-left-text-fill';
                    default: return 'bi-chat-left';
                }
            }

            function getCommentGroupColor(commentType) {
                switch (commentType) {
                    case 'Strengths': return 'success';
                    case 'Weaknesses': return 'warning';
                    case 'Additional Comments': return 'info';
                    default: return 'secondary';
                }
            }
            function createBarChart(canvasId, domains, title = '') {
                const ctx = document.getElementById(canvasId).getContext('2d');
                const labels = domains.map(d => d.DomainName);
                const rawScores = domains.map(d => (d.AvgScore / d.Weight) * 5);

                return new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Score (out of 5)',
                            data: rawScores,
                            backgroundColor: 'rgba(26, 58, 143, 0.7)',
                            borderColor: 'rgb(26, 58, 143)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 5,
                                title: {
                                    display: true,
                                    text: 'Score (1-5 Scale)'
                                },
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    title: function (tooltipItems) {
                                        return tooltipItems[0].label;
                                    },
                                    label: function (context) {
                                        const index = context.dataIndex;
                                        const rawScore = rawScores[index].toFixed(2);
                                        const weightedScore = domains[index].AvgScore.toFixed(1);
                                        const weight = domains[index].Weight;

                                        return [
                                            `Raw Score: ${rawScore}/5.00`,
                                            `Weighted Score: ${weightedScore}%`,
                                            `Domain Weight: ${weight}%`,
                                            `Calculation: (${rawScore} ÷ 5) × ${weight} = ${weightedScore}%`
                                        ];
                                    }
                                },
                                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                titleColor: '#1a3a8f',
                                bodyColor: '#343a40',
                                borderColor: '#1a3a8f',
                                borderWidth: 1,
                                padding: 12,
                                cornerRadius: 8
                            }
                        }
                    }
                });
            }

            // Utility functions
            function updateStars(score, selector) {
                const starRating = score / 20; // Convert percentage to 5-star scale
                const fullStars = Math.floor(starRating);
                const halfStar = (starRating - fullStars) >= 0.5;
                const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
                
                let starsHtml = '';
                starsHtml += '<i class="bi bi-star-fill text-warning"></i>'.repeat(fullStars);
                if (halfStar) {
                    starsHtml += '<i class="bi bi-star-half text-warning"></i>';
                }
                starsHtml += '<i class="bi bi-star text-warning"></i>'.repeat(emptyStars);
                $(selector).html(starsHtml);
            }

            function updateRatingBadge(score, selector) {
                let rating = 'Needs Improvement', ratingClass = 'badge-poor';
                if (score >= 90) { 
                    rating = 'Excellent'; 
                    ratingClass = 'badge-excellent'; 
                } else if (score >= 80) { 
                    rating = 'Very Good'; 
                    ratingClass = 'badge-good'; 
                } else if (score >= 70) { 
                    rating = 'Good'; 
                    ratingClass = 'badge-good'; 
                } else if (score >= 60) { 
                    rating = 'Average'; 
                    ratingClass = 'badge-average'; 
                }
                
                $(selector).text(rating).attr('class', `rating-badge ${ratingClass}`);
            }

            function escapeHtml(text) {
                if (!text) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }

            function formatDisplayDate(dateString) {
                if (!dateString || dateString === 'N/A') return 'N/A';
                try {
                    const date = new Date(dateString);
                    return isNaN(date.getTime()) ? dateString : 
                        date.toLocaleDateString('en-US', { 
                            month: 'short', 
                            day: 'numeric', 
                            year: 'numeric' 
                        });
                } catch (e) {
                    return dateString;
                }
            }

            // AJAX helper function
            function callPageMethod(methodName, params) {
                return new Promise((resolve, reject) => {
                    PageMethods[methodName](
                        ...params,
                        function(response) {
                            resolve(response);
                        },
                        function(error) {
                            reject(error);
                        }
                    );
                });
            }

            async function refreshData() {
                await Promise.all([
                    loadFacultyOverview(),
                    loadEvaluationStatus()
                ]);
                
                showAlert('Data refreshed successfully', 'success');
            }

            function showAlert(message, type, duration = 5000) {
                const alertContainer = document.getElementById('alertContainer');
                const alertId = 'alert-' + Date.now();
                
                const alertClass = type === 'success' ? 'alert-success' : 
                                 type === 'warning' ? 'alert-warning' : 'alert-danger';
                const icon = type === 'success' ? 'bi-check-circle' : 
                            type === 'warning' ? 'bi-exclamation-triangle' : 'bi-exclamation-circle';
                
                const alertHTML = `
                    <div id="${alertId}" class="alert ${alertClass} alert-dismissible fade show alert-slide" role="alert">
                        <i class="bi ${icon} me-2"></i>
                        ${message}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                `;
                
                alertContainer.insertAdjacentHTML('beforeend', alertHTML);
                
                if (duration > 0) {
                    setTimeout(() => {
                        const alert = document.getElementById(alertId);
                        if (alert) {
                            alert.remove();
                        }
                    }, duration);
                }
            }

            // Public API
            return {
                init: function() { 
                    $(document).ready(initialize); 
                },
                
                selectSubject: function(loadID, subjectName, subjectCode, term, overallScore, cycleName, cycleID) {
                    $('.subject-item').removeClass('active');
                    $(`[onclick*="selectSubject(${loadID},"]`).addClass('active');
                    
                    $('#<%= hdnSelectedLoadID.ClientID %>').val(loadID);
                    $('#<%= hdnSelectedCycleID.ClientID %>').val(cycleID);
                    
                    $('#overviewSection').hide();
                    $('#subjectSection').show();
                    
                    loadSubjectDetails(loadID.toString(), cycleID, subjectName, subjectCode, term, overallScore, cycleName, 1);
                },
                
                selectCombinedSubject: function(loadIDs, subjectName, subjectCode, term, overallScore, cycleName, cycleID, classCount) {
                    $('.subject-item').removeClass('active');
                    $(`[onclick*="selectCombinedSubject('${loadIDs}',"]`).addClass('active');
                    
                    $('#<%= hdnSelectedLoadID.ClientID %>').val(0);
                    $('#<%= hdnSelectedCycleID.ClientID %>').val(cycleID);
                    
                    $('#overviewSection').hide();
                    $('#subjectSection').show();
                    
                    loadSubjectDetails(loadIDs, cycleID, subjectName, subjectCode, term, overallScore, cycleName, classCount);
                },
                
                showFacultyOverview: function() {
                    $('#subjectSection').hide();
                    $('#overviewSection').show();
                    $('.subject-item').removeClass('active');
                },
                
                clearCycle: function() {
                    $('#<%= txtCycle.ClientID %>').val('');
                    $('#<%= hdnCycleID.ClientID %>').val('0');
                    localStorage.removeItem('selectedCycle');
                    setTimeout(() => $('#<%= btnFilter.ClientID %>').click(), 100);
                },
                
                clearSubjectSearch: function() {
                    $('#<%= txtSubjectSearch.ClientID %>').val('');
                    setTimeout(() => $('#<%= btnFilter.ClientID %>').click(), 100);
                },

                clearAllFilters: function () {
                    this.clearSubjectSearch();
                    this.clearCycle();
                },

                refreshData: refreshData
            };
        })();

        // Global functions for HTML onclick handlers
        function selectSubject(loadID, subjectName, subjectCode, term, overallScore, cycleName, cycleID) {
            FacultyResults.selectSubject(loadID, subjectName, subjectCode, term, overallScore, cycleName, cycleID);
        }

        function selectCombinedSubject(loadIDs, subjectName, subjectCode, term, overallScore, cycleName, cycleID, classCount) {
            FacultyResults.selectCombinedSubject(loadIDs, subjectName, subjectCode, term, overallScore, cycleName, cycleID, classCount);
        }

        function showFacultyOverview() {
            FacultyResults.showFacultyOverview();
        }

        function clearCycle() {
            FacultyResults.clearCycle();
        }

        function clearSubjectSearch() {
            FacultyResults.clearSubjectSearch();
        }

        function clearAllFilters() {
            FacultyResults.clearAllFilters();
        }

        // Initialize the module
        FacultyResults.init();
    </script>
</body>
</html>

