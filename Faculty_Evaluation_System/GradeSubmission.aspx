<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GradeSubmission.aspx.vb" Inherits="Faculty_Evaluation_System.GradeSubmission" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Submit Grades - Golden West Colleges</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
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
        
        /* Form controls */
        .form-control, .form-select {
            border: 1px solid #d1d3e2;
            border-radius: 0.35rem;
            padding: 0.75rem 1rem;
            transition: all 0.3s ease;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.1);
        }
        
        /* File upload area */
        .file-upload-area {
            border: 2px dashed #d1d3e2;
            border-radius: 0.5rem;
            padding: 2rem;
            text-align: center;
            background: #f8f9fc;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .file-upload-area:hover, .file-upload-area.dragover {
            border-color: var(--primary);
            background: #eef2ff;
        }
        
        /* Submission items */
        .submission-item {
            background: white;
            border: 1px solid #e3e6f0;
            border-radius: 0.5rem;
            padding: 1.25rem;
            margin-bottom: 1rem;
            transition: all 0.3s ease;
            border-left: 4px solid var(--primary);
        }
        
        .submission-item:hover {
            box-shadow: 0 0.25rem 0.75rem rgba(0, 0, 0, 0.1);
        }
        
        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .status-pending { background: #fff3cd; color: #856404; }
        .status-submitted { background: #d1ecf1; color: #0c5460; }
        .status-approved { background: #d4edda; color: #155724; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        
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
        
        /* Progress bar */
        .upload-progress {
            height: 6px;
            border-radius: 3px;
            overflow: hidden;
            background: #e3e6f0;
            margin-top: 0.5rem;
        }
        
        .progress-bar {
            height: 100%;
            background: var(--primary);
            transition: width 0.3s ease;
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
            
            .content .d-flex.justify-content-between h3 {
                font-size: 1.5rem;
            }
            
            .file-upload-area {
                padding: 1.5rem 1rem;
            }
            
            .sidebar .list-group-item {
                padding: 1rem 1.5rem;
            }
        }
        
        /* Mobile adjustments for better touch targets */
        @media (max-width: 768px) {
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
        /* Spin animation for refresh button */
.spin-animation {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

/* Cycle Folder Styles */
.cycle-folder {
    border: 1px solid #e3e6f0;
    transition: all 0.3s ease;
    border-left: 4px solid var(--primary);
}

.cycle-folder:hover {
    transform: translateY(-2px);
    box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
}

.cycle-folder.has-submissions {
    border-left-color: var(--primary);
}

.cycle-folder.no-submissions {
    border-left-color: var(--secondary);
    opacity: 0.7;
}

.cycle-folder .cycle-stats {
    border-top: 1px solid #e3e6f0;
    border-bottom: 1px solid #e3e6f0;
    padding: 1rem 0;
    margin: 1rem 0;
}

.cycle-folder .cycle-details {
    font-size: 0.875rem;
}

.cycle-folder .btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

/* Subject Card Styles */
.subject-card {
    border: 1px solid #e3e6f0;
    transition: all 0.3s ease;
}

.subject-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 0.25rem 0.75rem rgba(0, 0, 0, 0.1);
}

.subject-details small {
    line-height: 1.4;
}

/* Status badges */
.status-badge {
    padding: 0.4rem 0.8rem;
    border-radius: 20px;
    font-size: 0.75rem;
    font-weight: 600;
    white-space: nowrap;
}

.status-pending { background: #fff3cd; color: #856404; }
.status-submitted { background: #d1ecf1; color: #0c5460; }
.status-approved { background: #d4edda; color: #155724; }
.status-rejected { background: #f8d7da; color: #721c24; }

/* Panel transitions */
#classesPanel, #historyPanel {
    transition: opacity 0.3s ease;
}

/* Button group spacing */
.btn-group .btn {
    margin-right: 0.5rem;
}

.btn-group .btn:last-child {
    margin-right: 0;
}

/* Mobile responsive adjustments */
@media (max-width: 768px) {
    .btn-group {
        flex-wrap: wrap;
    }
    
    .btn-group .btn {
        margin-bottom: 0.5rem;
    }
    
    .cycle-stats .col-3 {
        margin-bottom: 0.5rem;
    }
}
/* Simplified submission items */
.submission-item {
    background: white;
    border: 1px solid #e3e6f0;
    border-radius: 0.5rem;
    padding: 1rem;
    margin-bottom: 0.75rem;
    transition: all 0.3s ease;
    border-left: 3px solid var(--primary);
}

.submission-item:hover {
    box-shadow: 0 0.15rem 0.5rem rgba(0, 0, 0, 0.1);
}

/* Clean status badges */
.status-badge {
    padding: 0.35rem 0.7rem;
    border-radius: 15px;
    font-size: 0.75rem;
    font-weight: 600;
    white-space: nowrap;
}

.status-pending { background: #fff3cd; color: #856404; }
.status-submitted { background: #d1ecf1; color: #0c5460; }
.status-approved { background: #d4edda; color: #155724; }
.status-rejected { background: #f8d7da; color: #721c24; }

/* Clean cycle folders */
.cycle-folder {
    border: 1px solid #e3e6f0;
    transition: all 0.3s ease;
    border-left: 4px solid var(--primary);
}

.cycle-folder:hover {
    transform: translateY(-2px);
    box-shadow: 0 0.25rem 0.75rem rgba(0, 0, 0, 0.1);
}

.cycle-folder.has-submissions {
    border-left-color: var(--primary);
}

.cycle-folder.no-submissions {
    border-left-color: #6c757d;
    opacity: 0.6;
}

.cycle-stats {
    border-top: 1px solid #e3e6f0;
    border-bottom: 1px solid #e3e6f0;
    padding: 0.75rem 0;
    margin: 0.75rem 0;
}

.cycle-details small {
    line-height: 1.5;
}

/* Modal improvements */
.modal-body {
    padding: 1.5rem;
}

.modal-header {
    padding: 1rem 1.5rem;
    border-bottom: 1px solid #e3e6f0;
}

.modal-footer {
    padding: 1rem 1.5rem;
    border-top: 1px solid #e3e6f0;
}

/* Form control static styling */
.form-control-static {
    padding: 0.5rem 0;
    margin: 0;
    color: #495057;
    font-weight: 500;
}

/* Empty state improvements */
.empty-state {
    padding: 2rem 1rem;
    text-align: center;
}

.empty-state i {
    font-size: 2.5rem;
    margin-bottom: 1rem;
}

/* Button spacing */
.btn-group .btn {
    margin-right: 0.5rem;
}

.btn-group .btn:last-child {
    margin-right: 0;
}
.cycle-folder {
    border: 1px solid #e3e6f0;
    transition: all 0.3s ease;
    border-left: 4px solid var(--primary);
}

.cycle-folder:hover {
    transform: translateY(-2px);
    box-shadow: 0 0.15rem 0.5rem rgba(0, 0, 0, 0.1);
}

.cycle-folder.has-submissions {
    border-left-color: var(--primary);
}

.cycle-folder.no-submissions {
    border-left-color: #6c757d;
    opacity: 0.6;
}

.cycle-status {
    font-size: 0.75rem;
}

/* Clean status badges */
.status-badge {
    padding: 0.35rem 0.7rem;
    border-radius: 15px;
    font-size: 0.75rem;
    font-weight: 600;
    white-space: nowrap;
}

.status-pending { background: #fff3cd; color: #856404; }
.status-submitted { background: #d1ecf1; color: #0c5460; }
.status-approved { background: #d4edda; color: #155724; }
.status-rejected { background: #f8d7da; color: #721c24; }
/* Folder Grid Styles matching SubmissionHistory.aspx */
.folder-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
    gap: 1rem;
    padding: 1rem 0;
}

.folder-item {
    text-align: center;
    padding: 0.75rem 0.5rem;
    border-radius: 8px;
    transition: all 0.3s ease;
    cursor: pointer;
    background: white;
    border: 1px solid #e3e6f0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
}

.folder-item:hover {
    transform: translateY(-3px);
    box-shadow: 0 0.3rem 1rem rgba(0,0,0,0.1);
    border-color: var(--primary);
}

.folder-icon {
    width: 50px;
    height: 40px;
    background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
    border-radius: 6px;
    position: relative;
    margin: 0 auto 0.5rem;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
}

.folder-item:hover .folder-icon {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
}

.folder-icon::before {
    content: '';
    position: absolute;
    top: -5px;
    left: 8px;
    width: 20px;
    height: 5px;
    background: inherit;
    border-radius: 3px 3px 0 0;
}

.folder-icon i {
    color: white;
    font-size: 1.2rem;
    z-index: 1;
}

.cycle-name {
    font-weight: 600;
    color: var(--primary);
    margin-bottom: 0.2rem;
    font-size: 0.8rem;
    line-height: 1.2;
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

.submission-count {
    font-size: 0.75rem;
    color: #6c757d;
}

@media (max-width: 768px) {
    .folder-grid {
        grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
        gap: 0.75rem;
    }

    .folder-item {
        padding: 0.5rem 0.25rem;
    }

    .cycle-name {
        font-size: 0.75rem;
    }
}
/* Compact modal improvements */
.compact-modal .modal-body {
    padding: 1rem;
}

.compact-modal .modal-header {
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #e3e6f0;
}

.compact-modal .modal-footer {
    padding: 0.75rem 1rem;
    border-top: 1px solid #e3e6f0;
}

.compact-modal .card {
    margin-bottom: 0.75rem;
}

.compact-modal .card-body {
    padding: 0.75rem;
}

/* Submission grid for compact view */
.submission-grid {
    display: grid;
    gap: 0.5rem;
}

.submission-grid-item {
    background: white;
    border: 1px solid #e3e6f0;
    border-radius: 0.375rem;
    padding: 0.75rem;
    transition: all 0.2s ease;
    border-left: 3px solid var(--primary);
}

.submission-grid-item:hover {
    box-shadow: 0 0.125rem 0.375rem rgba(0, 0, 0, 0.1);
    transform: translateY(-1px);
}

.submission-header {
    display: flex;
    justify-content: between;
    align-items: flex-start;
    margin-bottom: 0.5rem;
}

.submission-title {
    flex: 1;
}

.submission-actions {
    display: flex;
    gap: 0.25rem;
}

.submission-details {
    font-size: 0.8rem;
    color: #6c757d;
    line-height: 1.4;
}

.submission-details .detail-item {
    margin-bottom: 0.2rem;
}

/* Small button styles */
.btn-sm-compact {
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
    border-radius: 0.25rem;
}

/* Status badges for compact view */
.status-badge-sm {
    padding: 0.25rem 0.5rem;
    border-radius: 12px;
    font-size: 0.7rem;
    font-weight: 600;
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
                <small class="text-white-50">Faculty Evaluation System (Faculty Dashboard)</small>
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
                
                <a href="GradeSubmission.aspx" class="list-group-item list-group-item-action active">
                    <i class="bi bi-cloud-upload"></i>
                    <span class="list-group-text">Submit Grades</span>
                </a>
                <a href="FacultyResult.aspx" class="list-group-item list-group-item-action">
                    <i class="bi bi-graph-up"></i>
                    <span class="list-group-text">Evaluation Results</span>
                </a>
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
    <h3 class="dashboard-title"><i class="bi bi-cloud-upload me-2 gold-accent"></i>Grade Submission</h3>
    <div class="btn-group">
        <button type="button" id="btnViewClasses" class="btn btn-primary d-none">
            <i class="bi bi-arrow-left me-1"></i>Back to Classes
        </button>
        <button type="button" id="btnViewHistory" class="btn btn-outline-primary">
            <i class="bi bi-folder me-1"></i>Submission History
        </button>
        <button type="button" id="btnRefresh" class="btn btn-outline-secondary d-none">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>
</div>

    <!-- Classes Panel (Default View) -->
    <div id="classesPanel">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0 text-primary">
                    <i class="bi bi-list-ul me-2"></i>My Classes - Current Term
                </h5>
            </div>
            <div class="card-body">
                <div id="classesGrid" class="row">
                    <div class="col-12 text-center py-4">
                        <div class="loading-spinner-full text-primary mx-auto mb-3"></div>
                        <p class="text-muted mb-0">Loading your classes...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

   <!-- History Panel (Hidden by Default) -->
<div id="historyPanel" class="d-none">
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0 text-primary">
                <i class="bi bi-folder me-2"></i>Submission History by Evaluation Cycle
            </h5>
        </div>
        <div class="card-body">
            <!-- Folder Grid -->
            <div class="folder-grid" id="historyGrid">
                <!-- Folder items will be loaded here -->
            </div>

            <!-- Empty State -->
            <div id="historyEmptyState" class="text-center py-5" style="display: none;">
                <i class="bi bi-journal-x display-1 text-muted mb-3"></i>
                <h4 class="text-muted">No historical submissions found</h4>
                <p class="text-muted">You haven't submitted any grade sheets for past evaluation cycles.</p>
            </div>
        </div>
    </div>
</div>
</div>

<!-- Upload File Modal -->
<div class="modal fade compact-modal" id="uploadModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h6 class="modal-title" id="uploadModalLabel">Submit Grade Sheet</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- Subject Info -->
                <div class="mb-3">
                    <label class="form-label">Subject</label>
                    <div class="card">
                        <div class="card-body py-2">
                            <div id="modalSubjectDetails" class="subject-details">
                                <!-- Subject details will be loaded here -->
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cycle Info -->
                <div class="mb-3">
                    <label class="form-label">Evaluation Cycle</label>
                    <div class="card">
                        <div class="card-body py-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <strong id="cycleNameDisplay" class="d-block">Loading...</strong>
                                    <small class="text-muted" id="cycleTermDisplay"></small>
                                </div>
                                <span class="badge bg-success" id="cycleActiveBadge">Active</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- File Upload -->
                <div class="mb-3">
                    <label class="form-label">Grade Sheet File</label>
                    <div class="file-upload-area" id="uploadArea">
                        <div class="text-center">
                            <i class="bi bi-cloud-arrow-up text-primary mb-2" style="font-size: 1.5rem;"></i>
                            <p class="small mb-1">Drag & Drop or Click to Upload</p>
                            <p class="small text-muted mb-0">Excel (.xlsx, .xls), CSV • Max 10MB</p>
                        </div>
                    </div>
                    <input type="file" id="fileInput" class="d-none" accept=".xlsx,.xls,.csv" />
                    <div id="fileInfo" class="small mt-2"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sm btn-primary" id="submitBtn">
                    <i class="bi bi-check-lg me-1"></i>Submit
                </button>
            </div>
        </div>
    </div>
</div>
   <!-- View Submission Modal -->
<div class="modal fade compact-modal" id="viewModal" tabindex="-1" aria-labelledby="viewModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h6 class="modal-title" id="viewModalLabel">Submission Details</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- Subject Info -->
                <div class="mb-3">
                    <label class="form-label">Subject</label>
                    <div class="card">
                        <div class="card-body py-2">
                            <div id="viewSubjectDetails" class="subject-details">
                                <!-- Subject details will be loaded here -->
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Submission Details -->
                <div class="row mb-3">
                    <div class="col-6">
                        <label class="form-label">Cycle</label>
                        <p id="viewCycle" class="small mb-1">-</p>
                    </div>
                    <div class="col-6">
                        <label class="form-label">Submitted</label>
                        <p id="viewSubmissionDate" class="small mb-1">-</p>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Status</label>
                        <p><span id="viewStatus" class="status-badge status-pending">-</span></p>
                    </div>
                </div>

                <!-- File Info -->
                <div class="mb-3" id="fileSection">
                    <label class="form-label">File</label>
                    <div id="fileInfoCard" class="card">
                        <div class="card-body py-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center">
                                    <i class="bi bi-file-earmark-excel text-success me-2"></i>
                                    <div>
                                        <div id="viewFileName" class="small">Grade Sheet</div>
                                        <div class="text-muted" id="viewFileSize" style="font-size: 0.7rem;">-</div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-sm btn-outline-primary" id="viewDownloadBtn">
                                    <i class="bi bi-download"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div id="noFileMessage" class="alert alert-warning py-2 d-none" style="font-size: 0.875rem;">
                        <i class="bi bi-exclamation-triangle me-1"></i>No file submitted
                    </div>
                </div>

                <!-- Remarks -->
                <div id="viewRemarksSection" class="d-none">
                    <label class="form-label">Remarks</label>
                    <div class="card">
                        <div class="card-body py-2">
                            <p id="viewRemarks" class="small mb-0">-</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

    </form>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Global variables
        let currentFacultyId = <%= If(Session("UserID") IsNot Nothing, Session("UserID"), "0") %>;
        let currentLoadId = 0;
        let currentSubject = {};
        let currentView = 'classes'; // 'classes' or 'history'
        let currentCycleID = 0;

        $(document).ready(function () {
            if (currentFacultyId > 0) {
                initializePage();
                setupEventHandlers();
            } else {
                showError("Please log in to access this page.");
            }
        });

        function initializePage() {
            loadClasses();
            loadCycleHistory();
        }

        function setupEventHandlers() {
            // View toggle buttons
            $('#btnViewClasses').click(function (e) {
                e.preventDefault();
                switchToView('classes');
            });

            $('#btnViewHistory').click(function (e) {
                e.preventDefault();
                switchToView('history');
            });

            // Refresh button
            $('#btnRefresh').click(function (e) {
                e.preventDefault();
                refreshCurrentView();
            });

            // File upload handlers
            setupFileUploadHandlers();
        }

        function switchToView(view) {
            if (currentView === view) return;

            currentView = view;

            // Update button states
            if (view === 'classes') {
                $('#btnViewHistory').removeClass('d-none'); // Show history button
                $('#btnViewClasses').addClass('d-none'); // Hide back button
                $('#btnRefresh').addClass('d-none'); // Show refresh button
                $('#classesPanel').removeClass('d-none');
                $('#historyPanel').addClass('d-none');
            } else {
                $('#btnViewHistory').addClass('d-none'); // Hide history button
                $('#btnViewClasses').removeClass('d-none'); // Show back button
                $('#btnRefresh').addClass('d-none'); // Hide refresh button
                $('#historyPanel').removeClass('d-none');
                $('#classesPanel').addClass('d-none');
            }
        }

        function refreshCurrentView() {
            const btn = $('#btnRefresh');
            const icon = btn.find('.bi-arrow-clockwise');

            // Show loading state
            btn.prop('disabled', true);
            icon.addClass('spin-animation');

            if (currentView === 'classes') {
                loadClasses();
            } else {
                loadCycleHistory();
            }

            // Restore button state after a delay
            setTimeout(function () {
                btn.prop('disabled', false);
                icon.removeClass('spin-animation');
            }, 1000);
        }

        // ==================== CLASSES FUNCTIONS ====================

        function loadClasses() {
            $.ajax({
                type: "POST",
                url: "GradeSubmission.aspx/GetFacultyClasses",
                data: JSON.stringify({ facultyID: currentFacultyId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        if (data.Success) {
                            renderClassesGrid(data.Data);
                        } else {
                            showError(data.Message || 'Failed to load classes');
                        }
                    } catch (e) {
                        showError('Error loading classes: ' + e.message);
                    }
                },
                error: function (xhr, status, error) {
                    showError('Network error loading classes: ' + error);
                }
            });
        }

        function renderClassesGrid(classes) {
            const classesGrid = $('#classesGrid');

            if (!classes || classes.length === 0) {
                classesGrid.html(`
            <div class="col-12">
                <div class="empty-state">
                    <i class="bi bi-folder-x text-muted" style="font-size: 3rem;"></i>
                    <h5 class="text-muted mt-3">No Classes Assigned</h5>
                    <p class="text-muted">You don't have any classes assigned for the current term.</p>
                </div>
            </div>
        `);
                return;
            }

            let html = '';

            classes.forEach(cls => {
                const statusClass = cls.GradeSubmitted ? 'status-submitted' : 'status-pending';
                const statusText = cls.GradeSubmitted ? 'Submitted' : 'Pending';
                const buttonText = cls.GradeSubmitted ? 'View Submission' : 'Upload Grades';
                const buttonClass = cls.GradeSubmitted ? 'btn-outline-primary' : 'btn-primary';
                const buttonIcon = cls.GradeSubmitted ? 'bi-eye' : 'bi-cloud-upload';

                html += `
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card subject-card h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <h5 class="card-title text-primary">${escapeHtml(cls.SubjectCode)}</h5>
                            <span class="status-badge ${statusClass}">${statusText}</span>
                        </div>
                        <h6 class="card-subtitle mb-2">${escapeHtml(cls.SubjectName)}</h6>
                        <div class="subject-details">
                            <small class="text-muted d-block">
                                <i class="bi bi-people me-1"></i>${escapeHtml(cls.YearLevel)} - ${escapeHtml(cls.Section)}
                            </small>
                            <small class="text-muted d-block">
                                <i class="bi bi-book me-1"></i>${escapeHtml(cls.CourseName)}
                            </small>
                        </div>
                    </div>
                    <div class="card-footer bg-transparent">
                        <button type="button" class="btn ${buttonClass} w-100 subject-action-btn" 
                                data-load-id="${cls.LoadID}" 
                                data-submitted="${cls.GradeSubmitted}">
                            <i class="bi ${buttonIcon} me-1"></i>
                            ${buttonText}
                        </button>
                    </div>
                </div>
            </div>`;
            });

            classesGrid.html(html);

            // Add event listeners to subject action buttons
            $('.subject-action-btn').click(function (e) {
                e.preventDefault();
                const loadId = $(this).data('load-id');
                const isSubmitted = $(this).data('submitted');

                if (isSubmitted) {
                    viewClassSubmission(loadId);
                } else {
                    openUploadModal(loadId);
                }
            });
        }

        function openUploadModal(loadId) {
            // Find the subject details from the current classes data
            const subjectCards = $('.subject-card');
            let subject = null;

            subjectCards.each(function () {
                const btn = $(this).find('.subject-action-btn');
                if (btn.data('load-id') === loadId) {
                    const title = $(this).find('.card-title').text();
                    const subtitle = $(this).find('.card-subtitle').text();
                    const yearLevel = $(this).find('.subject-details small:first-child').text();
                    const courseName = $(this).find('.subject-details small:last-child').text();

                    subject = {
                        SubjectCode: title,
                        SubjectName: subtitle,
                        YearLevel: yearLevel,
                        CourseName: courseName
                    };
                    return false; // break loop
                }
            });

            if (subject) {
                currentLoadId = loadId;
                currentSubject = subject;

                // Update modal subject details (compact version)
                $('#modalSubjectDetails').html(`
            <strong class="d-block">${escapeHtml(subject.SubjectCode)}</strong>
            <div class="text-muted">${escapeHtml(subject.SubjectName)}</div>
            <small class="text-muted">
                ${escapeHtml(subject.YearLevel)} • ${escapeHtml(subject.CourseName)}
            </small>
        `);

                // Reset file input
                $('#fileInput').val('');
                $('#fileInfo').html('');
                $('#uploadProgress').addClass('d-none');
                $('#progressBar').css('width', '0%');

                // Load and display the latest evaluation cycle
                loadLatestCycle();

                // Show modal
                const uploadModal = new bootstrap.Modal(document.getElementById('uploadModal'));
                uploadModal.show();
            } else {
                showError('Subject details not found');
            }
        }



        // ==================== HISTORY FUNCTIONS ====================

        function loadCycleHistory() {
            $.ajax({
                type: "POST",
                url: "GradeSubmission.aspx/GetSubmissionHistoryByCycle",
                data: JSON.stringify({ facultyID: currentFacultyId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        if (data.Success) {
                            renderCycleHistory(data.Data);
                        } else {
                            showError(data.Message || 'Failed to load submission history');
                        }
                    } catch (e) {
                        showError('Error loading submission history: ' + e.message);
                    }
                },
                error: function (xhr, status, error) {
                    showError('Network error loading history: ' + error);
                }
            });
        }

        function renderCycleHistory(cycles) {
            const historyGrid = $('#historyGrid');
            const historyEmptyState = $('#historyEmptyState');

            if (!cycles || cycles.length === 0) {
                historyGrid.html('');
                historyEmptyState.show();
                return;
            }

            historyEmptyState.hide();

            let html = '';
            cycles.forEach(cycle => {
                const hasSubmissions = cycle.SubmissionCount > 0;
                const statusClass = getCycleStatusClass(cycle);
                const statusText = getCycleStatusText(cycle);

                html += `
        <div class="folder-item" onclick="viewCycleDetails(${cycle.CycleID}, '${escapeHtml(cycle.CycleName)}')">
            <div class="folder-icon">
                <i class="bi bi-folder"></i>
            </div>
            <div class="cycle-name" title="${escapeHtml(cycle.CycleName)}">
                ${escapeHtml(cycle.CycleName)}
            </div>
            <div class="submission-count">
                ${cycle.SubmissionCount} submission(s)
            </div>
           
        </div>`;
            });

            historyGrid.html(html);
        }

        function getCycleStatusClass(cycle) {
            if (cycle.ApprovedCount > 0 && cycle.PendingCount === 0 && cycle.RejectedCount === 0) {
                return 'status-approved';
            } else if (cycle.RejectedCount > 0) {
                return 'status-rejected';
            } else if (cycle.PendingCount > 0) {
                return 'status-pending';
            } else {
                return 'status-pending';
            }
        }

        function getCycleStatusText(cycle) {
            if (cycle.ApprovedCount > 0 && cycle.PendingCount === 0 && cycle.RejectedCount === 0) {
                return 'Completed';
            } else if (cycle.RejectedCount > 0) {
                return 'Needs Review';
            } else if (cycle.PendingCount > 0) {
                return 'In Progress';
            } else {
                return 'No Submissions';
            }
        }

        function viewCycleDetails(cycleId, cycleName) {
            showLoading('Loading cycle details...');

            $.ajax({
                type: "POST",
                url: "GradeSubmission.aspx/GetSubmissionHistory",
                data: JSON.stringify({ facultyID: currentFacultyId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    hideLoading();
                    try {
                        const data = JSON.parse(response.d);
                        if (data.Success) {
                            const cycleSubmissions = data.Data.filter(sub => sub.CycleID === cycleId);
                            showCycleSubmissionsModal(cycleSubmissions, cycleName);
                        } else {
                            showError('Failed to load cycle details');
                        }
                    } catch (e) {
                        showError('Error loading cycle details: ' + e.message);
                    }
                },
                error: function (xhr, status, error) {
                    hideLoading();
                    showError('Network error loading cycle details: ' + error);
                }
            });
        }
        function showCycleSubmissionsModal(submissions, cycleName) {
            let html = '';

            if (submissions && submissions.length > 0) {
                html += `<div class="submission-grid">`;

                submissions.forEach(sub => {
                    const statusClass = getStatusClass(sub.Status);
                    const statusText = getStatusText(sub.Status);
                    const hasFile = sub.FileID && sub.FileID > 0;

                    html += `
            <div class="submission-grid-item">
                <div class="submission-header">
                    <div class="submission-title">
                        <h6 class="text-primary mb-1">${escapeHtml(sub.SubjectCode)}</h6>
                        <div class="text-muted small">${escapeHtml(sub.SubjectName)}</div>
                    </div>
                    <div class="submission-actions">
                        <span class="status-badge-sm ${statusClass}">${statusText}</span>
                        ${hasFile ?
                            `<button type="button" class="btn btn-outline-primary btn-sm-compact download-submission-btn ms-1" 
                                data-fileid="${sub.FileID}" data-filename="${escapeHtml(sub.FileName)}"
                                title="Download ${escapeHtml(sub.FileName)}">
                                <i class="bi bi-download"></i>
                            </button>` :
                            `<span class="btn btn-outline-secondary btn-sm-compact disabled ms-1" title="No file available">
                                <i class="bi bi-download"></i>
                            </span>`
                        }
                    </div>
                </div>
                
                <div class="submission-details">
                    <div class="detail-item">
                        <strong>Class:</strong> ${escapeHtml(sub.YearLevel || '')} - ${escapeHtml(sub.Section || '')}
                    </div>
                    <div class="detail-item">
                        <strong>Course:</strong> ${escapeHtml(sub.CourseName || 'N/A')}
                    </div>
                    <div class="detail-item">
                        <strong>Submitted:</strong> ${formatDateTime(sub.SubmissionDate)}
                    </div>
                    ${sub.Remarks && sub.Remarks.trim() !== '' ?
                            `<div class="detail-item">
                            <strong>Remarks:</strong> ${escapeHtml(sub.Remarks)}
                        </div>` : ''
                        }
                </div>
            </div>`;
                });

                html += `</div>`;
            } else {
                html = `
        <div class="empty-state">
            <i class="bi bi-inbox text-muted" style="font-size: 2rem;"></i>
            <h6 class="text-muted mt-2">No Submissions</h6>
            <p class="text-muted small">No grade sheets submitted for this cycle.</p>
        </div>`;
            }

            // Create modal for cycle submissions
            const modalId = 'cycleSubmissionsModal';
            const existingModal = document.getElementById(modalId);
            if (existingModal) {
                existingModal.remove();
            }

            const modalHtml = `
    <div class="modal fade compact-modal" id="${modalId}" tabindex="-1" aria-labelledby="${modalId}Label" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title" id="${modalId}Label">
                        <i class="bi bi-folder2-open me-2"></i>${escapeHtml(cycleName)}
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="max-height: 60vh; overflow-y: auto;">
                    <div class="mb-3">
                        <small class="text-muted">
                            ${submissions ? submissions.length : 0} submission(s) in this cycle
                        </small>
                    </div>
                    ${html}
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>`;

            $('body').append(modalHtml);

            const modal = new bootstrap.Modal(document.getElementById(modalId));
            modal.show();

            // Add event listeners to download buttons
            $(`#${modalId} .download-submission-btn`).click(function (e) {
                e.preventDefault();
                e.stopPropagation();
                const fileId = $(this).data('fileid');
                const fileName = $(this).data('filename');
                downloadSubmissionFile(fileId, fileName);
            });
        }


        // ==================== SUBMISSION VIEW FUNCTIONS ====================

        function viewClassSubmission(loadId) {
            showLoading('Loading submission details...');

            // We need to get ALL submissions (including current cycle) for this specific class
            $.ajax({
                type: "POST",
                url: "GradeSubmission.aspx/GetAllSubmissionsForClass",
                data: JSON.stringify({ loadID: loadId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    hideLoading();
                    try {
                        const data = JSON.parse(response.d);
                        if (data.Success && data.Data) {
                            viewSubmissionDetails(data.Data);
                        } else {
                            showError(data.Message || 'No submission found for this class');
                        }
                    } catch (e) {
                        showError('Error loading submission details: ' + e.message);
                    }
                },
                error: function (xhr, status, error) {
                    hideLoading();
                    showError('Network error loading submission: ' + error);
                }
            });
        }

        function viewSubmissionDetails(submission) {
            console.log('Full submission data:', submission);

            // Update modal title with subject info
            $('#viewSubjectTitle').text('Subject Information');

            // Update subject details (compact version)
            $('#viewSubjectDetails').html(`
        <strong class="d-block">${escapeHtml(submission.SubjectCode)}</strong>
        <div class="text-muted">${escapeHtml(submission.SubjectName)}</div>
        <small class="text-muted">
            ${escapeHtml(submission.CycleName)} • ${escapeHtml(submission.Term)}
        </small>
    `);

            // Update submission information
            $('#viewCycle').text(`${submission.CycleName} - ${submission.Term}`);

            // FIXED: Better date handling with multiple fallbacks
            let submissionDate = 'Date not available';
            if (submission.SubmissionDate && submission.SubmissionDate.trim() !== '') {
                submissionDate = formatDateTime(submission.SubmissionDate);
            } else if (submission.FileSubmissionDate && submission.FileSubmissionDate.trim() !== '') {
                submissionDate = formatDateTime(submission.FileSubmissionDate);
            } else {
                // If no date is found in the data, try to get current date as fallback
                submissionDate = 'Recently submitted'; // Generic message since we don't have the actual date
            }
            $('#viewSubmissionDate').text(submissionDate);

            // Update status - with better handling
            const statusText = getStatusText(submission.Status);
            const statusClass = getStatusClass(submission.Status);
            $('#viewStatus').text(statusText);
            $('#viewStatus').attr('class', `status-badge ${statusClass}`);

            // Handle file information
            const hasFile = submission.FileID && submission.FileID > 0;
            if (hasFile) {
                $('#fileInfoCard').removeClass('d-none');
                $('#noFileMessage').addClass('d-none');

                $('#viewFileName').text(submission.FileName || 'Grade Sheet');

                let fileSizeText = 'File size: Not available';
                if (submission.FileSize) {
                    fileSizeText = `File size: ${formatFileSize(submission.FileSize)}`;
                }
                $('#viewFileSize').text(fileSizeText);

                // Enable download button
                const downloadBtn = $('#viewDownloadBtn');
                downloadBtn.prop('disabled', false);
                downloadBtn.off('click').on('click', function () {
                    downloadSubmissionFile(submission.FileID, submission.FileName);
                });
            } else {
                $('#fileInfoCard').addClass('d-none');
                $('#noFileMessage').removeClass('d-none');
            }

            // Handle remarks
            if (submission.Remarks && submission.Remarks.trim() !== '') {
                $('#viewRemarksSection').removeClass('d-none');
                $('#viewRemarks').text(submission.Remarks);
            } else {
                $('#viewRemarksSection').addClass('d-none');
            }

            // Show modal
            const viewModal = new bootstrap.Modal(document.getElementById('viewModal'));
            viewModal.show();
        }

        function formatDateSimple(dateString) {
            if (!dateString) return 'N/A';

            try {
                // Handle MySQL date format: YYYY-MM-DD
                if (dateString.match(/^\d{4}-\d{2}-\d{2}$/)) {
                    const [year, month, day] = dateString.split('-');
                    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    return `${monthNames[parseInt(month) - 1]} ${parseInt(day)}, ${year}`;
                }
                return dateString;
            } catch (e) {
                return 'Invalid date';
            }
        }
        // ==================== FILE UPLOAD FUNCTIONS ====================

        function setupFileUploadHandlers() {
            const fileInput = document.getElementById('fileInput');
            const uploadArea = document.getElementById('uploadArea');

            // File input change handler
            fileInput.addEventListener('change', handleFileSelect);

            // Drag and drop functionality
            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                uploadArea.addEventListener(eventName, preventDefaults, false);
            });

            function preventDefaults(e) {
                e.preventDefault();
                e.stopPropagation();
            }

            ['dragenter', 'dragover'].forEach(eventName => {
                uploadArea.addEventListener(eventName, highlight, false);
            });

            ['dragleave', 'drop'].forEach(eventName => {
                uploadArea.addEventListener(eventName, unhighlight, false);
            });

            function highlight() {
                uploadArea.classList.add('dragover');
            }

            function unhighlight() {
                uploadArea.classList.remove('dragover');
            }

            uploadArea.addEventListener('drop', handleDrop, false);

            function handleDrop(e) {
                const dt = e.dataTransfer;
                const files = dt.files;
                fileInput.files = files;
                handleFileSelect();
            }

            // Upload area click handler
            uploadArea.addEventListener('click', function () {
                fileInput.click();
            });

            // Submit button handler
            $('#submitBtn').click(function (e) {
                e.preventDefault();
                submitGrades();
            });
        }

        function handleFileSelect() {
            const file = document.getElementById('fileInput').files[0];
            if (file) {
                const fileSize = (file.size / (1024 * 1024)).toFixed(2);
                $('#fileInfo').html(`
            <div class="alert alert-success py-2 d-flex align-items-center" style="font-size: 0.875rem;">
                <i class="bi bi-check-circle-fill text-success me-2"></i>
                <div>
                    <strong>${escapeHtml(file.name)}</strong> (${fileSize} MB)
                </div>
            </div>
        `);
            }
        }
        function submitGrades() {
            const fileInput = document.getElementById('fileInput');
            const submitBtn = $('#submitBtn');
            const originalText = submitBtn.html();

            // Validation
            if (currentCycleID === 0) {
                showError('No evaluation cycle available. Please try again.');
                return;
            }

            if (!fileInput.files.length) {
                showError('Please select a file to upload.');
                return;
            }

            const file = fileInput.files[0];
            const maxSize = 10 * 1024 * 1024; // 10MB

            // Validate file type
            const validTypes = ['.xlsx', '.xls', '.csv'];
            const fileExtension = '.' + file.name.split('.').pop().toLowerCase();

            if (!validTypes.includes(fileExtension)) {
                showError('Please select a valid Excel (.xlsx, .xls) or CSV file.');
                return;
            }

            if (file.size > maxSize) {
                showError('File size must be less than 10MB.');
                return;
            }

            submitBtn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm me-2"></span> Submitting...');

            // Show progress bar
            const progressBar = document.getElementById('progressBar');
            const uploadProgress = document.getElementById('uploadProgress');
            if (uploadProgress) {
                uploadProgress.classList.remove('d-none');
                progressBar.style.width = '30%';
            }

            // Read file as base64
            const reader = new FileReader();
            reader.onload = function (e) {
                if (uploadProgress) {
                    progressBar.style.width = '70%';
                }

                const base64Content = e.target.result.split(',')[1];

                $.ajax({
                    type: "POST",
                    url: "GradeSubmission.aspx/SubmitGradeFile",
                    data: JSON.stringify({
                        loadID: currentLoadId,
                        cycleID: currentCycleID,
                        facultyID: currentFacultyId,
                        fileName: file.name,
                        fileContent: base64Content
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    timeout: 30000, // 30 second timeout
                    success: function (response) {
                        if (uploadProgress) {
                            progressBar.style.width = '100%';
                        }

                        try {
                            const result = JSON.parse(response.d);
                            if (result.Success) {
                                showSuccess(result.Message || 'Grade sheet submitted successfully!');
                                // Close modal and refresh classes
                                const uploadModal = bootstrap.Modal.getInstance(document.getElementById('uploadModal'));
                                if (uploadModal) {
                                    uploadModal.hide();
                                }
                                setTimeout(() => {
                                    loadClasses();
                                }, 1000);
                            } else {
                                showError(result.Message || 'Failed to submit grade sheet');
                            }
                        } catch (e) {
                            showError('Error processing server response: ' + e.message);
                        }

                        submitBtn.prop('disabled', false).html(originalText);
                        if (uploadProgress) {
                            setTimeout(() => {
                                uploadProgress.classList.add('d-none');
                                progressBar.style.width = '0%';
                            }, 1000);
                        }
                    },
                    error: function (xhr, status, error) {
                        let errorMsg = 'Network error: Unable to submit grade sheet. ';
                        if (status === 'timeout') {
                            errorMsg += 'Request timed out. Please try again.';
                        } else {
                            errorMsg += error;
                        }
                        showError(errorMsg);
                        submitBtn.prop('disabled', false).html(originalText);
                        if (uploadProgress) {
                            uploadProgress.classList.add('d-none');
                            progressBar.style.width = '0%';
                        }
                    }
                });
            };

            reader.onerror = function () {
                showError('Error reading the file. Please try again.');
                submitBtn.prop('disabled', false).html(originalText);
                if (uploadProgress) {
                    uploadProgress.classList.add('d-none');
                    progressBar.style.width = '0%';
                }
            };

            reader.readAsDataURL(file);
        }
        function handleCycleLoadError() {
            $('#cycleNameDisplay').text('Error loading cycle');
            $('#cycleTermDisplay').text('Please refresh and try again');
            $('#submitBtn').prop('disabled', true);
            showError('Failed to load evaluation cycle. Please refresh the page.');
        }

        // ==================== UTILITY FUNCTIONS ====================

        function getStatusClass(status) {
            switch (status) {
                case 'Confirmed': return 'status-approved';
                case 'Rejected': return 'status-rejected';
                case 'Submitted': return 'status-submitted';
                default: return 'status-pending';
            }
        }

        function getStatusText(status) {
            switch (status) {
                case 'Confirmed': return 'Approved';
                case 'Rejected': return 'Rejected';
                case 'Submitted': return 'Under Review';
                default: return 'Pending';
            }
        }

        function formatDate(dateString) {
            console.log('formatDate received:', dateString); // Debug log

            if (!dateString || dateString === 'undefined' || dateString === 'null') {
                return 'Date not available';
            }

            // If it's already a formatted string we like, return it
            if (typeof dateString === 'string' && dateString.includes('/')) {
                return dateString;
            }

            try {
                let date;

                // Handle different date formats
                if (dateString instanceof Date) {
                    date = dateString;
                } else if (typeof dateString === 'string') {
                    // Try direct parsing first
                    date = new Date(dateString);

                    // If that fails, try parsing common formats
                    if (isNaN(date.getTime())) {
                        // MySQL date format: YYYY-MM-DD
                        if (dateString.match(/^\d{4}-\d{2}-\d{2}$/)) {
                            const [year, month, day] = dateString.split('-');
                            date = new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
                        }
                        // MySQL datetime format: YYYY-MM-DD HH:MM:SS
                        else if (dateString.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/)) {
                            const [datePart, timePart] = dateString.split(' ');
                            const [year, month, day] = datePart.split('-');
                            const [hours, minutes, seconds] = timePart.split(':');
                            date = new Date(
                                parseInt(year),
                                parseInt(month) - 1,
                                parseInt(day),
                                parseInt(hours),
                                parseInt(minutes),
                                parseInt(seconds)
                            );
                        }
                        // Handle ISO format with T and Z
                        else if (dateString.includes('T')) {
                            date = new Date(dateString);
                        }
                    }
                } else {
                    return 'Invalid date format';
                }

                // Check if we have a valid date
                if (!date || isNaN(date.getTime())) {
                    console.warn('Invalid date after parsing:', dateString);
                    return 'Date format error';
                }

                // Format the date nicely
                const options = {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric'
                };

                return date.toLocaleDateString('en-US', options);

            } catch (error) {
                console.error('Error in formatDate:', error, 'Input:', dateString);
                return 'Date error';
            }
        }

        // Special function for dates with time
        function formatDateTime(dateString) {
            console.log('Raw date string:', dateString);

            if (!dateString || dateString === 'undefined' || dateString === 'null' || dateString.trim() === '') {
                return 'Date not available';
            }

            try {
                // For MySQL format: "2025-10-30 09:09:41"
                if (typeof dateString === 'string') {
                    // Handle MySQL datetime format
                    const mysqlMatch = dateString.match(/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/);
                    if (mysqlMatch) {
                        const [_, year, month, day, hours, minutes, seconds] = mysqlMatch;
                        const date = new Date(year, month - 1, day, hours, minutes, seconds);

                        if (!isNaN(date.getTime())) {
                            const options = {
                                year: 'numeric',
                                month: 'short',
                                day: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit'
                            };
                            return date.toLocaleDateString('en-US', options);
                        }
                    }

                    // Try direct parsing as fallback
                    const date = new Date(dateString);
                    if (!isNaN(date.getTime())) {
                        const options = {
                            year: 'numeric',
                            month: 'short',
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                        };
                        return date.toLocaleDateString('en-US', options);
                    }
                }

                return 'Invalid date format';

            } catch (error) {
                console.error('Error formatting date:', error);
                return 'Date format error';
            }
        }

        function formatFileSize(bytes) {
            if (!bytes || bytes === 0 || isNaN(bytes)) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        function escapeHtml(unsafe) {
            if (unsafe === null || unsafe === undefined) return '';
            return unsafe
                .toString()
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }

        function downloadSubmissionFile(fileId, fileName) {
            window.open('DownloadGradeFile.aspx?fileID=' + fileId, '_blank');
        }

        function showLoading(message = 'Loading...') {
            // You can implement a loading overlay here if needed
            console.log('Loading: ' + message);
        }

        function hideLoading() {
            // Hide loading overlay if implemented
        }

        function showError(message) {
            showAlert(message, 'danger');
        }

        function showSuccess(message) {
            showAlert(message, 'success');
        }

        function showAlert(message, type) {
            const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            const icon = type === 'success' ? 'bi-check-circle' : 'bi-exclamation-triangle';

            const alert = $(`
        <div class="alert ${alertClass} alert-dismissible fade show alert-slide" role="alert">
            <i class="bi ${icon} me-2"></i>
            ${escapeHtml(message)}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `);

            $('#alertContainer').html(alert);

            setTimeout(() => {
                alert.alert('close');
            }, 5000);
        }

        // Auto-refresh every 5 minutes
        setInterval(() => {
            if (currentView === 'classes') {
                loadClasses();
            } else {
                loadCycleHistory();
            }
        }, 300000);
        function debugDateData(cycles) {
            console.log('=== DATE DATA DEBUGGING ===');
            if (cycles && cycles.length > 0) {
                cycles.forEach((cycle, index) => {
                    console.log(`Cycle ${index + 1}:`, {
                        CycleName: cycle.CycleName,
                        StartDate: cycle.StartDate,
                        EndDate: cycle.EndDate,
                        LatestSubmission: cycle.LatestSubmission,
                        'StartDate raw': cycle.StartDate,
                        'EndDate raw': cycle.EndDate,
                        'LatestSubmission raw': cycle.LatestSubmission,
                        'StartDate type': typeof cycle.StartDate,
                        'EndDate type': typeof cycle.EndDate,
                        'LatestSubmission type': typeof cycle.LatestSubmission
                    });
                });
            } else {
                console.log('No cycles data received or empty array');
            }
            console.log('=== END DEBUGGING ===');
        }

        // Update your loadCycleHistory function to call the debug function
        function loadCycleHistory() {
            $.ajax({
                type: "POST",
                url: "GradeSubmission.aspx/GetSubmissionHistoryByCycle",
                data: JSON.stringify({ facultyID: currentFacultyId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        if (data.Success) {
                            // Debug the data first
                            debugDateData(data.Data);
                            renderCycleHistory(data.Data);
                        } else {
                            showError(data.Message || 'Failed to load submission history');
                        }
                    } catch (e) {
                        showError('Error loading submission history: ' + e.message);
                    }
                },
                error: function (xhr, status, error) {
                    showError('Network error loading history: ' + error);
                }
            });
        }
        // Function to load and select the latest cycle
        function loadLatestCycle() {
            // Show loading state
            $('#cycleNameDisplay').html('<span class="spinner-border spinner-border-sm me-2"></span>Loading cycle...');
            $('#cycleTermDisplay').text('');
            $('#cycleDateDisplay').text('');
            $('#cycleActiveIcon').addClass('d-none');
            $('#submitBtn').prop('disabled', true);

            $.ajax({
                type: "POST",
                url: "GradeSubmission.aspx/GetLatestEvaluationCycle",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        if (data.Success && data.Data) {
                            const cycle = data.Data;
                            currentCycleID = cycle.CycleID;

                            // Update cycle display
                            $('#cycleNameDisplay').text(cycle.CycleName);
                            $('#cycleTermDisplay').text(cycle.Term);

                            // Format and display dates
                            if (cycle.StartDate && cycle.EndDate) {
                                const startDate = formatDateSimple(cycle.StartDate);
                                const endDate = formatDateSimple(cycle.EndDate);
                                $('#cycleDateDisplay').text(`${startDate} to ${endDate}`);
                            }

                            // Show appropriate status indicator
                            if (cycle.Status === 'Active') {
                                $('#cycleActiveIcon').removeClass('d-none text-warning').addClass('text-success');
                                $('#cycleActiveIcon').next('small').text('Active');
                            } else {
                                $('#cycleActiveIcon').removeClass('d-none text-success').addClass('text-warning');
                                $('#cycleActiveIcon').next('small').text('Inactive');
                            }

                            $('#submitBtn').prop('disabled', false);

                            console.log('Using cycle:', cycle.CycleName, 'ID:', currentCycleID, 'Status:', cycle.Status);
                        } else {
                            $('#cycleNameDisplay').text('No evaluation cycle found');
                            $('#cycleTermDisplay').text('Please contact administrator');
                            $('#cycleActiveIcon').addClass('d-none');
                            $('#submitBtn').prop('disabled', true);
                            showError('No evaluation cycle found. Please contact administrator.');
                        }
                    } catch (e) {
                        console.error('Error parsing latest cycle:', e);
                        handleCycleLoadError();
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error loading latest cycle:', error);
                    handleCycleLoadError();
                }
            });
        }


        // Fallback function to load all cycles
        function loadAllCycles() {
            $.ajax({
                type: "POST",
                url: "GradeSubmission.aspx/GetEvaluationCycles",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        if (data.Success && data.Data && data.Data.length > 0) {
                            const cycles = data.Data;
                            const ddlCycle = $('#ddlCycle');

                            ddlCycle.empty();
                            cycles.forEach(cycle => {
                                ddlCycle.append(new Option(
                                    `${cycle.CycleName} - ${cycle.Term}`,
                                    cycle.CycleID
                                ));
                            });

                            // Auto-select the first one (which should be latest due to ordering)
                            if (cycles.length > 0) {
                                ddlCycle.val(cycles[0].CycleID);
                            }
                        } else {
                            $('#ddlCycle').html('<option value="">No evaluation cycles available</option>');
                        }
                    } catch (e) {
                        console.error('Error loading cycles:', e);
                        $('#ddlCycle').html('<option value="">Error loading cycles</option>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Network error loading cycles:', error);
                    $('#ddlCycle').html('<option value="">Network error</option>');
                }
            });
        }
    </script>
</body>
</html>

