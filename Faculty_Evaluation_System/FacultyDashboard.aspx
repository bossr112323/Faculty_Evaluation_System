<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="FacultyDashboard.aspx.vb" Inherits="Faculty_Evaluation_System.FacultyDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/1999/xhtml" lang="en">
<head runat="server">
    <title>Faculty Dashboard - Golden West Colleges</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Golden West Colleges Faculty Evaluation System Dashboard" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" />
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
            overflow-x: hidden;
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
            z-index: 1030;
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
            z-index: 1020;
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
            min-height: calc(100vh - var(--header-height));
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
        
        .stat-card.total {
            border-left-color: var(--primary);
        }
        
        .stat-card.submitted {
            border-left-color: var(--success);
        }
        
        .stat-card.pending {
            border-left-color: var(--warning);
        }
        
        .stat-card.evaluated {
            border-left-color: var(--info);
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
            z-index: 1030;
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
            z-index: 1019;
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

        /* Classes table styling */
        .class-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .class-table th {
            background-color: #f8f9fa;
            color: var(--primary);
            font-weight: 600;
            padding: 0.75rem;
            text-align: left;
            border-bottom: 2px solid #dee2e6;
        }
        
        .class-table td {
            padding: 0.75rem;
            border-bottom: 1px solid #dee2e6;
            vertical-align: middle;
        }
        
        .class-table tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .status-badge {
            padding: 0.35em 0.65em;
            font-size: 0.75em;
            font-weight: 700;
            border-radius: 0.25rem;
        }
        
        .status-submitted {
            background-color: rgba(40, 167, 69, 0.1);
            color: var(--success);
        }
        
        .status-pending {
            background-color: rgba(255, 193, 7, 0.1);
            color: var(--warning);
        }
        
        /* Quick actions */
        .quick-actions {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-bottom: 1.5rem;
        }
        
        .quick-action-card {
            flex: 1;
            min-width: 150px;
            background: white;
            border-radius: 8px;
            padding: 1rem;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            transition: all 0.2s ease;
            border: 1px solid #e3e6f0;
        }
        
        .quick-action-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            border-color: var(--primary);
        }
        
        .quick-action-card i {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            color: var(--primary);
        }
        
        /* Progress bars */
        .progress {
            height: 8px;
            margin-top: 0.5rem;
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
            
            .quick-actions {
                flex-direction: column;
            }
            
            .quick-action-card {
                min-width: 100%;
            }
            
            .class-table {
                display: block;
                overflow-x: auto;
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
        
        /* Accessibility improvements */
        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }
        
        /* Focus states for better accessibility */
        .btn:focus,
        .list-group-item:focus,
        .dropdown-toggle:focus {
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
            outline: none;
        }
        
        /* Print styles */
        @media print {
            .sidebar,
            .header-bar,
            .btn,
            .alert,
            .quick-actions,
            .sidebar-toggler {
                display: none !important;
            }
            
            .content {
                margin: 0 !important;
                padding: 0 !important;
            }
            
            .card {
                box-shadow: none !important;
                border: 1px solid #ddd !important;
            }
        }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header-bar">
            <div class="d-flex align-items-center">
                <button id="mobileSidebarToggler" class="btn btn-sm btn-outline-secondary me-2 d-lg-none" type="button" aria-label="Toggle sidebar">
                    <i class="bi bi-list"></i>
                </button>
                <!-- Logo Section -->
                <div class="d-flex align-items-center me-3">
                    <img src="Image/logo.png" alt="Golden West Colleges Logo" class="header-logo me-2" 
                         style="height: 40px; width: auto; object-fit: contain;" 
                         onerror="this.style.display='none'" />
                    <div class="title-section">
                        <h3 class="mb-0 fw-bold text-white">Golden West Colleges Inc.</h3>
                        <small class="text-white-50">Faculty Evaluation System (Faculty Dashboard)</small>
                    </div>
                </div>
            </div>
            <div class="d-flex align-items-center">
                <!-- Department Info -->
                <span class="text-white d-none d-md-block me-3">
                    <i class="bi bi-building-gear me-1" aria-hidden="true"></i>
                    <asp:Label ID="lblDepartment" runat="server" CssClass="fw-bold"></asp:Label>
                </span>
                <!-- User Menu -->
                <div class="dropdown">
                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true">
                        <i class="bi bi-person-circle me-1" aria-hidden="true"></i>
                        <span class="d-none d-sm-inline"><asp:Label ID="lblFacultyName" runat="server" Text="Faculty" /></span>
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userMenu">
                        <li><a class="dropdown-item" href="ChangePassword.aspx"><i class="bi bi-key me-2" aria-hidden="true"></i>Change Password</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <asp:LinkButton ID="btnLogout" runat="server" CssClass="dropdown-item text-danger" OnClick="btnLogout_Click">
                                <i class="bi bi-box-arrow-right me-2" aria-hidden="true"></i>Logout
                            </asp:LinkButton>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Sidebar Overlay for Mobile -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- Sidebar -->
        <nav class="sidebar" id="sidebar" aria-label="Main navigation">
            <h6 class="sidebar-header px-3 text-uppercase">Main Navigation</h6>
            <div class="list-group list-group-flush">
                <a href="FacultyDashboard.aspx" class="list-group-item list-group-item-action active" aria-current="page">
                    <i class="bi bi-speedometer2" aria-hidden="true"></i>
                    <span class="list-group-text">Dashboard Overview</span>
                </a>
                <a href="GradeSubmission.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-cloud-upload" aria-hidden="true"></i>
                    <span class="list-group-text">Submit Grades</span>
                </a>
                <a href="FacultyResult.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-graph-up" aria-hidden="true"></i>
                    <span class="list-group-text">Evaluation Results</span>
                </a>
            </div>
        </nav>

        <!-- Main Content -->
        <main class="content" id="mainContent">
            <!-- Alert Container -->
            <div id="alertContainer" role="alert" aria-live="polite">
                <asp:Label ID="lblAlert" runat="server" CssClass="alert d-none alert-slide" />
            </div>

            <!-- Dashboard Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1 class="dashboard-title"><i class="bi bi-speedometer2 me-2 gold-accent" aria-hidden="true"></i>Faculty Dashboard</h1>
                <button id="btnRefresh" class="btn btn-outline-primary" aria-label="Refresh dashboard data">
                    <i class="bi bi-arrow-clockwise me-1" aria-hidden="true"></i>
                    <span class="d-none d-sm-inline">Refresh</span>
                    <span class="loading-spinner spinner-border spinner-border-sm ms-1" aria-hidden="true"></span>
                </button>
            </div>

            <!-- Statistics Overview -->
            <div class="row mb-4">
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stat-card total h-100">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs fw-bold text-primary text-uppercase mb-1">Total Classes</div>
                                    <div class="h5 mb-0 fw-bold text-gray-800" id="totalClasses">0</div>
                                    <div class="text-xs text-muted">Assigned this term</div>
                                    <div class="progress">
                                        <div class="progress-bar bg-primary" role="progressbar" id="totalClassesProgress" style="width: 100%" 
                                             aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-journals fa-2x text-primary" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                  <div class="col-xl-3 col-md-6 mb-4">
      <div class="card stat-card pending h-100">
          <div class="card-body">
              <div class="row align-items-center">
                  <div class="col mr-2">
                      <div class="text-xs fw-bold text-warning text-uppercase mb-1">Pending Grades</div>
                      <div class="h5 mb-0 fw-bold text-gray-800" id="pendingGrades">0</div>
                      <div class="text-xs text-muted">Awaiting submission</div>
                      <div class="progress">
                          <div class="progress-bar bg-warning" role="progressbar" id="pendingProgress" style="width: 0%" 
                               aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                      </div>
                  </div>
                  <div class="col-auto">
                      <i class="bi bi-clock fa-2x text-warning" aria-hidden="true"></i>
                  </div>
              </div>
          </div>
      </div>
  </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stat-card submitted h-100">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs fw-bold text-success text-uppercase mb-1">Grades Submitted</div>
                                    <div class="h5 mb-0 fw-bold text-gray-800" id="submittedGrades">0</div>
                                    <div class="text-xs text-muted">Completed submissions</div>
                                    <div class="progress">
                                        <div class="progress-bar bg-success" role="progressbar" id="submittedProgress" style="width: 0%" 
                                             aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-check-circle fa-2x text-success" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

              

                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card stat-card evaluated h-100">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs fw-bold text-info text-uppercase mb-1">Classes Evaluated</div>
                                    <div class="h5 mb-0 fw-bold text-gray-800" id="evaluatedClasses">0</div>
                                    <div class="text-xs text-muted">Evaluation completed</div>
                                    <div class="progress">
                                        <div class="progress-bar bg-info" role="progressbar" id="evaluatedProgress" style="width: 0%" 
                                             aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <i class="bi bi-graph-up fa-2x text-info" aria-hidden="true"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Classes Section -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h2 class="h5 mb-0 text-primary">
                                <i class="bi bi-journal-check me-2" aria-hidden="true"></i>My Classes This Term
                            </h2>
                            <span class="badge bg-primary" id="classesCount">0 Classes</span>
                        </div>
                        <div class="card-body">
                            <div id="classesList">
                                <div class="text-center py-5">
                                    <div class="loading-spinner-full mx-auto mb-3" aria-hidden="true"></div>
                                    <p class="text-muted">Loading your classes...</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

     
      
    </form>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Dashboard functionality
        $(document).ready(function () {
            // Initialize dashboard
            loadDashboardData();

            // Set up auto-refresh
            setupAutoRefresh();

            // Set up event handlers
            setupEventHandlers();
        });

        // Setup auto-refresh functionality
        function setupAutoRefresh() {
            // Auto-refresh every 5 minutes
            setInterval(() => {
                if (!document.hidden) {
                    loadDashboardData(true); // Silent refresh
                }
            }, 300000); // 5 minutes

            // Refresh when page becomes visible again
            document.addEventListener('visibilitychange', function () {
                if (!document.hidden) {
                    loadDashboardData(true);
                }
            });
        }

        // Setup event handlers
        function setupEventHandlers() {
            // Mobile sidebar toggler
            const mobileSidebarToggler = document.getElementById('mobileSidebarToggler');
            const sidebarOverlay = document.getElementById('sidebarOverlay');

            mobileSidebarToggler.addEventListener('click', function () {
                const sidebar = document.getElementById('sidebar');
                sidebar.classList.toggle('mobile-show');
                sidebarOverlay.classList.toggle('show');
            });

            // Close sidebar when clicking outside on mobile
            sidebarOverlay.addEventListener('click', function () {
                const sidebar = document.getElementById('sidebar');
                sidebar.classList.remove('mobile-show');
                sidebarOverlay.classList.remove('show');
            });

            // Handle alert messages
            const alertElement = document.getElementById('<%= lblAlert.ClientID %>');
            if (alertElement && alertElement.textContent.trim() !== '') {
                alertElement.classList.remove('d-none');

                // Auto-hide alert after 5 seconds
                setTimeout(function () {
                    alertElement.classList.add('d-none');
                }, 5000);
            }

            // Adjust sidebar on resize
            window.addEventListener('resize', function () {
                if (window.innerWidth >= 768) {
                    const sidebar = document.getElementById('sidebar');
                    sidebar.classList.remove('mobile-show');
                    sidebarOverlay.classList.remove('show');
                }
            });

            // Refresh button functionality
            document.getElementById('btnRefresh').addEventListener('click', function () {
                loadDashboardData(false, true);
            });
        }

        // Load dashboard data
        function loadDashboardData(silent = false, userInitiated = false) {
            if (!silent) {
                showLoadingState();
            }

            $.ajax({
                type: "POST",
                url: "FacultyDashboard.aspx/GetDashboardData",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        console.log("Full response:", response); // Debug log

                        // Parse the response
                        var data = JSON.parse(response.d);
                        console.log("Parsed data:", data); // Debug log

                        if (data.Success) {
                            updateStatistics(data.Data.Statistics);
                            displayClasses(data.Data.Classes);

                            if (!silent) {
                                showSuccess("Dashboard data loaded successfully");
                            }
                        } else {
                            if (!silent) {
                                showError(data.Message || "Failed to load dashboard data");
                            }
                        }
                    } catch (e) {
                        console.error("Error parsing response:", e);
                        if (!silent) {
                            showError("Error processing response: " + e.message);
                        }
                    } finally {
                        if (!silent) {
                            hideLoadingState();
                        }
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    if (!silent) {
                        showError("Error loading dashboard data: " + error);
                        hideLoadingState();
                    }
                }
            });
        }

        // Show loading state
        function showLoadingState() {
            const btn = document.getElementById('btnRefresh');
            const spinner = btn.querySelector('.loading-spinner');
            const icon = btn.querySelector('.bi-arrow-clockwise');

            // Show loading state
            icon.style.display = 'none';
            spinner.style.display = 'inline-block';
            btn.disabled = true;
        }

        // Hide loading state
        function hideLoadingState() {
            const btn = document.getElementById('btnRefresh');
            const spinner = btn.querySelector('.loading-spinner');
            const icon = btn.querySelector('.bi-arrow-clockwise');

            // Restore button state
            icon.style.display = 'inline-block';
            spinner.style.display = 'none';
            btn.disabled = false;
        }

        // Update statistics cards
        function updateStatistics(stats) {
            if (!stats) {
                console.error("No statistics data received");
                return;
            }

            console.log("Updating statistics:", stats); // Debug log

            const totalClasses = stats.TotalClasses || 0;
            const submittedGrades = stats.SubmittedGrades || 0;
            const pendingGrades = stats.PendingGrades || 0;
            const evaluatedClasses = stats.EvaluatedClasses || 0;

            // Update values
            $('#totalClasses').text(totalClasses);
            $('#submittedGrades').text(submittedGrades);
            $('#pendingGrades').text(pendingGrades);
            $('#evaluatedClasses').text(evaluatedClasses);

            // Update progress bars
            const submittedPercentage = totalClasses > 0 ? Math.round((submittedGrades / totalClasses) * 100) : 0;
            const pendingPercentage = totalClasses > 0 ? Math.round((pendingGrades / totalClasses) * 100) : 0;
            const evaluatedPercentage = totalClasses > 0 ? Math.round((evaluatedClasses / totalClasses) * 100) : 0;

            $('#submittedProgress').css('width', submittedPercentage + '%').attr('aria-valuenow', submittedPercentage);
            $('#pendingProgress').css('width', pendingPercentage + '%').attr('aria-valuenow', pendingPercentage);
            $('#evaluatedProgress').css('width', evaluatedPercentage + '%').attr('aria-valuenow', evaluatedPercentage);
        }

        // Display classes in the table
        function displayClasses(classes) {
            const container = $('#classesList');
            if (!classes || classes.length === 0) {
                container.html(`
                    <div class="empty-state">
                        <i class="bi bi-journal-x" style="font-size: 3rem; margin-bottom: 1rem;"></i>
                        <h5>No Classes Assigned</h5>
                        <p class="text-muted">You don't have any classes assigned for the current term.</p>
                    </div>
                `);
                $('#classesCount').text('0 Classes');
                return;
            }

            console.log("Displaying classes:", classes); // Debug log

            // Update classes count
            $('#classesCount').text(classes.length + ' Classes');

            let classesHtml = `
                <div class="table-responsive">
                    <table class="class-table">
                        <thead>
                            <tr>
                                <th>Subject Code</th>
                                <th>Subject Name</th>
                                <th>Class</th>
                                <th>Course</th>
                              
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>`;

            classes.forEach(cls => {
                if (!cls) return;

                // Determine status and badge
                const isSubmitted = cls.GradeStatus === 'Submitted' || cls.GradeStatus === 'Completed';
                const statusText = isSubmitted ? 'Submitted' : 'Pending';
                const statusClass = isSubmitted ? 'status-submitted' : 'status-pending';

                classesHtml += `
                    <tr>
                        <td class="fw-semibold">${cls.SubjectCode || 'N/A'}</td>
                        <td>${cls.SubjectName || 'N/A'}</td>
                        <td>${cls.YearLevel || 'N/A'}-${cls.Section || 'N/A'}</td>
                        <td>${cls.CourseName || 'N/A'}</td>
                     
                        <td>
                            <div class="d-flex gap-1 flex-wrap">
                                <a href="GradeSubmission.aspx?loadID=${cls.LoadID || 0}" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-cloud-upload me-1"></i>Grades
                                </a>
                                <a href="FacultyResult.aspx?loadID=${cls.LoadID || 0}" class="btn btn-sm btn-outline-success">
                                    <i class="bi bi-graph-up me-1"></i>Results
                                </a>
                            </div>
                        </td>
                    </tr>`;
            });

            classesHtml += '</tbody></table></div>';
            container.html(classesHtml);
        }

        // Show error message
        function showError(message) {
            showAlert(message, 'danger');
        }

        // Show success message
        function showSuccess(message) {
            showAlert(message, 'success');
        }

        // Show alert message
        function showAlert(message, type) {
            const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            const icon = type === 'success' ? 'bi-check-circle' : 'bi-exclamation-triangle';

            const alert = $(`
                <div class="alert ${alertClass} alert-dismissible fade show alert-slide" role="alert">
                    <i class="bi ${icon} me-2" aria-hidden="true"></i>
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            `);

            $('#alertContainer').html(alert);

            // Auto-remove success alerts after 5 seconds
            if (type === 'success') {
                setTimeout(() => {
                    alert.alert('close');
                }, 5000);
            }
        }
    </script>
</body>
</html>