<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Reports.aspx.vb" Inherits="Faculty_Evaluation_System.Reports" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Evaluation Analytics - Faculty Evaluation System</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.0.0"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
        line-height: 1.6;
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

    /* Sidebar headers */
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

    /* MAIN CONTENT IMPROVEMENTS */
    .content {
        margin-left: var(--sidebar-width);
        margin-top: var(--header-height);
        padding: 2rem;
        transition: all 0.3s ease;
        min-height: calc(100vh - var(--header-height));
        font-family: 'Poppins', 'Segoe UI', sans-serif;
    }

    .content.collapsed {
        margin-left: var(--sidebar-collapsed-width);
    }

    /* Improved Typography for Main Content */
    .page-title {
        color: var(--primary);
        border-bottom: 2px solid var(--gold);
        padding-bottom: 0.75rem;
        margin-bottom: 2rem;
        font-weight: 700;
        font-size: 2rem;
        letter-spacing: -0.5px;
    }

    .card {
        border: none;
        border-radius: 0.5rem;
        box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
        margin-bottom: 1.5rem;
        font-family: 'Poppins', sans-serif;
    }

    .card-header {
        background-color: #f8f9fc;
        border-bottom: 1px solid #e3e6f0;
        padding: 1rem 1.5rem;
        font-weight: 600;
        font-size: 1.1rem;
        color: var(--primary);
    }

    /* Improved Table Styling with Center Alignment */
    .table {
        font-family: 'Poppins', sans-serif;
        border-collapse: separate;
        border-spacing: 0;
        width: 100%;
    }

    .table th {
        background-color: var(--primary);
        color: white;
        font-weight: 600;
        text-transform: uppercase;
        font-size: 0.85rem;
        letter-spacing: 0.5px;
        padding: 1rem 0.75rem;
        text-align: center;
        border: none;
    }

    .table td {
        padding: 1rem 0.75rem;
        text-align: center;
        vertical-align: middle;
        border-bottom: 1px solid #e3e6f0;
        font-weight: 400;
    }

    .table-hover tbody tr:hover {
        background-color: rgba(26, 58, 143, 0.05);
        transform: translateY(-1px);
        transition: all 0.2s ease;
    }

    .table-responsive {
        border-radius: 0.5rem;
        overflow: hidden;
        box-shadow: 0 0.125rem 0.5rem rgba(0, 0, 0, 0.1);
    }

    /* Center align all table content */
    .table th,
    .table td {
        text-align: center !important;
    }

    /* Improved KPI Cards */
    .kpi-card {
        border-left: 4px solid;
        transition: all 0.3s ease;
        height: 100%;
        border-radius: 0.5rem;
        text-align: center;
    }

    .kpi-card.faculty { border-left-color: var(--primary); }
    .kpi-card.subjects { border-left-color: var(--success); }
    .kpi-card.participation { border-left-color: var(--info); }
    .kpi-card.average { border-left-color: var(--gold); }

    .kpi-card .card-body {
        padding: 1.5rem;
    }

    .kpi-value {
        font-size: 2.5rem;
        font-weight: 700;
        color: var(--primary);
        line-height: 1;
        margin: 0.5rem 0;
    }

    /* Improved Chart Containers */
    .chart-container {
        position: relative;
        height: 300px;
        width: 100%;
        font-family: 'Poppins', sans-serif;
    }

    .radar-chart-container {
        position: relative;
        height: 400px;
        width: 100%;
    }

    /* Improved Tabs */
    .nav-tabs {
        border-bottom: 2px solid #e3e6f0;
        margin-bottom: 2rem;
    }

    .nav-tabs .nav-link {
        border: none;
        color: var(--secondary);
        font-weight: 500;
        padding: 0.75rem 1.5rem;
        margin-bottom: -2px;
        transition: all 0.3s ease;
    }

    .nav-tabs .nav-link.active {
        background-color: transparent;
        border-bottom: 3px solid var(--gold);
        font-weight: 600;
        color: var(--primary);
    }

    .tab-pane {
        padding-top: 1.5rem;
    }

    /* Improved Score Styling */
    .faculty-score {
        font-size: 1.75rem;
        font-weight: 700;
        display: block;
        text-align: center;
    }

    .score-excellent { color: var(--success); }
    .score-good { color: var(--info); }
    .score-average { color: var(--gold); }
    .score-poor { color: var(--danger); }

    /* Improved Button Styling */
    .btn {
        font-weight: 500;
        border-radius: 0.375rem;
        transition: all 0.3s ease;
        font-family: 'Poppins', sans-serif;
    }

    .btn-primary {
        background-color: var(--primary);
        border-color: var(--primary);
    }

    .btn-primary:hover {
        background-color: var(--primary-dark);
        border-color: var(--primary-dark);
        transform: translateY(-1px);
    }

    /* Improved Form Controls */
    .form-control, .form-select {
        border-radius: 0.375rem;
        border: 1px solid #e3e6f0;
        padding: 0.5rem 0.75rem;
        font-family: 'Poppins', sans-serif;
        transition: all 0.3s ease;
    }

    .form-control:focus, .form-select:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
    }

    /* Simplified Faculty Details Modal */
    .modal-content {
        border-radius: 0.75rem;
        border: none;
        box-shadow: 0 1rem 3rem rgba(0, 0, 0, 0.175);
    }

    .modal-header {
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
        color: white;
        border-bottom: 2px solid var(--gold);
        padding: 1.5rem;
    }

    .modal-title {
        font-weight: 600;
        font-size: 1.25rem;
    }

    .modal-body {
        padding: 2rem;
    }

    /* Simplified Subject List in Modal */
    .subject-item {
        transition: all 0.2s ease;
        border-radius: 0.5rem;
        margin-bottom: 0.75rem;
        text-align: left;
    }

    .subject-item:hover {
        background-color: #f8f9fa;
        border-color: var(--primary) !important;
        transform: translateX(5px);
    }

    .subject-item.active-subject {
        border-color: var(--primary) !important;
        background-color: #e7f1ff !important;
    }

    .subject-name {
        font-size: 0.95rem;
        line-height: 1.3;
        font-weight: 500;
    }

    /* Improved Comments Section */
    .comment-group .card {
        transition: all 0.3s ease;
        border-radius: 0.5rem;
    }

    .comment-group .card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }

    .comment-item {
        transition: all 0.2s ease;
        border-radius: 0.375rem;
    }

    .comment-item:hover {
        background-color: #f8f9fa !important;
    }

    .comment-text {
        font-size: 0.95rem;
        line-height: 1.5;
        color: #495057;
    }

    /* Utility Classes */
    .text-center {
        text-align: center !important;
    }

    .gold-accent {
        color: var(--gold);
    }

    .cursor-pointer {
        cursor: pointer;
    }

    /* Loading States */
    .loading-spinner {
        display: inline-block;
        width: 2rem;
        height: 2rem;
        border: 0.25em solid currentColor;
        border-right-color: transparent;
        border-radius: 50%;
        animation: spin 0.75s linear infinite;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    /* Responsive Adjustments */
    @media (max-width: 768px) {
        .content {
            padding: 1rem;
            margin-left: 0;
        }

        .content.collapsed {
            margin-left: 0;
        }

        .sidebar {
            left: calc(-1 * var(--sidebar-width));
            width: var(--sidebar-width);
        }

        .sidebar.mobile-show {
            left: 0;
        }

        .page-title {
            font-size: 1.5rem;
        }

        .table-responsive {
            font-size: 0.875rem;
        }

        .kpi-value {
            font-size: 2rem;
        }

        .chart-container {
            height: 250px;
        }
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

    /* Mobile menu button styling */
    #mobileSidebarToggler {
        background: rgba(255, 255, 255, 0.2);
        border-color: rgba(255, 255, 255, 0.5);
        color: white;
    }

    #mobileSidebarToggler:hover {
        background: rgba(255, 255, 255, 0.3);
    }

    /* Print Styles */
    @media print {
        .no-print {
            display: none !important;
        }
    }
    /* Improved Search Container Alignment */
.search-container {
    position: relative;
    display: flex;
    align-items: center;
}

.search-icon {
    position: absolute;
    left: 12px;
    top: 50%;
    transform: translateY(-50%);
    color: #6c757d;
    z-index: 3;
}

.search-input {
    padding-left: 40px;
    padding-right: 40px;
    width: 100%;
}

.search-clear {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    color: #6c757d;
    cursor: pointer;
    z-index: 3;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 20px;
    height: 20px;
}

/* Improved Form Label Alignment */
.form-label {
    font-weight: 500;
    color: var(--primary);
    margin-bottom: 0.5rem;
    font-size: 0.9rem;
}

/* Improved Filter Form Row Alignment */
.filter-form .row {
    align-items: end;
}

.filter-form .col-md-8,
.filter-form .col-md-4,
.filter-form .col-md-3 {
    display: flex;
    flex-direction: column;
}

/* Ensure consistent form control heights */
.form-control, .form-select {
    height: calc(2.5rem + 2px);
    display: flex;
    align-items: center;
}

/* Improved Card Body Padding */
.card-body {
    padding: 1.5rem;
}

/* Better alignment for filter header */
.card-header.d-flex {
    align-items: center;
}

/* Improved manual refresh button alignment */
.btn-outline-primary {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
}

/* Enhanced autocomplete suggestions alignment */
.autocomplete-suggestions {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border: 1px solid #dee2e6;
    border-top: none;
    border-radius: 0 0 0.375rem 0.375rem;
    max-height: 200px;
    overflow-y: auto;
    z-index: 1000;
    display: none;
    box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.suggestion-item {
    padding: 0.75rem 1rem;
    cursor: pointer;
    border-bottom: 1px solid #f8f9fa;
    display: flex;
    flex-direction: column;
    transition: background-color 0.2s ease;
}

.suggestion-item:hover {
    background-color: #f8f9fa;
}

.suggestion-primary {
    font-weight: 500;
    color: #212529;
    font-size: 0.9rem;
}

.suggestion-secondary {
    font-size: 0.8rem;
    color: #6c757d;
    margin-top: 0.25rem;
}

/* Fix dropdown alignment */
.form-select {
    background-position: right 0.75rem center;
    padding-right: 2.5rem;
}

/* Improved filter card layout */
.filter-form .row.g-3 {
    margin-bottom: 0;
}

/* Better last updated text alignment */
.small.text-muted {
    font-size: 0.8rem;
    display: flex;
    align-items: center;
}

/* Responsive adjustments for filters */
@media (max-width: 768px) {
    .filter-form .col-md-8,
    .filter-form .col-md-4,
    .filter-form .col-md-3 {
        margin-bottom: 1rem;
    }
    
    .search-container {
        margin-bottom: 0;
    }
    
    .card-header.d-flex {
        flex-direction: column;
        align-items: flex-start;
        gap: 1rem;
    }
    
    .card-header .d-flex.align-items-center.gap-2 {
        align-self: flex-end;
    }
}
/* IMPROVED ACTION BUTTON COLORS */
.btn-action-primary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
    border-color: var(--primary);
    color: white;
    font-weight: 600;
    font-size: 0.875rem;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    transition: all 0.3s ease;
    box-shadow: 0 2px 4px rgba(26, 58, 143, 0.2);
}

.btn-action-primary:hover {
    background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 100%);
    border-color: var(--primary-dark);
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(26, 58, 143, 0.3);
}

.btn-action-primary:active {
    transform: translateY(0);
    box-shadow: 0 2px 4px rgba(26, 58, 143, 0.2);
}

.btn-action-secondary {
    background: linear-gradient(135deg, var(--gold) 0%, var(--gold-light) 100%);
    border-color: var(--gold);
    color: #333;
    font-weight: 600;
    font-size: 0.875rem;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    transition: all 0.3s ease;
    box-shadow: 0 2px 4px rgba(212, 175, 55, 0.2);
}

.btn-action-secondary:hover {
    background: linear-gradient(135deg, var(--gold-dark) 0%, var(--gold) 100%);
    border-color: var(--gold-dark);
    color: #333;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(212, 175, 55, 0.3);
}

.btn-action-outline {
    background: transparent;
    border: 2px solid var(--primary);
    color: var(--primary);
    font-weight: 600;
    font-size: 0.875rem;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    transition: all 0.3s ease;
}

.btn-action-outline:hover {
    background: var(--primary);
    border-color: var(--primary);
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(26, 58, 143, 0.2);
}

/* Status-based action buttons */
.btn-action-success {
    background: linear-gradient(135deg, var(--success) 0%, #34ce87 100%);
    border-color: var(--success);
    color: white;
    font-weight: 600;
    font-size: 0.875rem;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    transition: all 0.3s ease;
}

.btn-action-success:hover {
    background: linear-gradient(135deg, #218838 0%, var(--success) 100%);
    border-color: #218838;
    color: white;
    transform: translateY(-2px);
}

.btn-action-warning {
    background: linear-gradient(135deg, var(--warning) 0%, #ffd54f 100%);
    border-color: var(--warning);
    color: #333;
    font-weight: 600;
    font-size: 0.875rem;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    transition: all 0.3s ease;
}

.btn-action-warning:hover {
    background: linear-gradient(135deg, #e0a800 0%, var(--warning) 100%);
    border-color: #e0a800;
    color: #333;
    transform: translateY(-2px);
}

.btn-action-danger {
    background: linear-gradient(135deg, var(--danger) 0%, #e4606d 100%);
    border-color: var(--danger);
    color: white;
    font-weight: 600;
    font-size: 0.875rem;
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    transition: all 0.3s ease;
}

.btn-action-danger:hover {
    background: linear-gradient(135deg, #c82333 0%, var(--danger) 100%);
    border-color: #c82333;
    color: white;
    transform: translateY(-2px);
}

/* Improved small action buttons for tables */
.btn-sm {
    padding: 0.375rem 0.75rem;
    font-size: 0.8125rem;
    border-radius: 0.25rem;
}

/* Specific improvements for existing buttons */
.btn-outline-primary {
    border: 2px solid var(--primary);
    color: var(--primary);
    font-weight: 500;
    transition: all 0.3s ease;
}

.btn-outline-primary:hover {
    background: var(--primary);
    border-color: var(--primary);
    color: white;
    transform: translateY(-1px);
    box-shadow: 0 2px 6px rgba(26, 58, 143, 0.2);
}

.btn-primary {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
    border-color: var(--primary);
    font-weight: 600;
    transition: all 0.3s ease;
}

.btn-primary:hover {
    background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 100%);
    border-color: var(--primary-dark);
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(26, 58, 143, 0.3);
}

/* Enhanced button icons */
.btn i {
    transition: transform 0.2s ease;
}

.btn:hover i {
    transform: scale(1.1);
}

/* Improved button groups in tables */
.action-buttons {
    display: flex;
    gap: 0.5rem;
    justify-content: center;
    align-items: center;
}

.action-buttons .btn {
    display: flex;
    align-items: center;
    gap: 0.375rem;
    white-space: nowrap;
}

/* Responsive button adjustments */
@media (max-width: 768px) {
    .action-buttons {
        flex-direction: column;
        gap: 0.25rem;
    }
    
    .action-buttons .btn {
        width: 100%;
        justify-content: center;
    }
    
    .btn-sm {
        padding: 0.5rem 0.75rem;
        font-size: 0.8rem;
    }
}

/* Special button for view actions */
.btn-view {
    background: linear-gradient(135deg, var(--info) 0%, #3bd5f0 100%);
    border-color: var(--info);
    color: white;
    font-weight: 600;
}

.btn-view:hover {
    background: linear-gradient(135deg, #138496 0%, var(--info) 100%);
    border-color: #138496;
    color: white;
}

/* Special button for analytics/insights */
.btn-analytics {
    background: linear-gradient(135deg, #6f42c1 0%, #8c68d6 100%);
    border-color: #6f42c1;
    color: white;
    font-weight: 600;
}

.btn-analytics:hover {
    background: linear-gradient(135deg, #59359f 0%, #6f42c1 100%);
    border-color: #59359f;
    color: white;
}

/* Button focus states for accessibility */
.btn:focus {
    box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
    outline: none;
}

.btn-action-primary:focus {
    box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.5);
}

/* Disabled state improvements */
.btn:disabled {
    opacity: 0.6;
    transform: none !important;
    box-shadow: none !important;
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
                <a href="Reports.aspx" class="list-group-item list-group-item-action active">
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
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none mb-3 alert-slide" />

            <div class="d-flex justify-content-between align-items-center mb-4 page-header">
                <h2 class="mb-0 page-title"><i class="bi bi-graph-up me-2 gold-accent"></i>Evaluation Analytics</h2>
            </div>
            
            <!-- Main Tabs -->
            <ul class="nav nav-tabs mb-4" id="analyticsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="institution-tab" data-bs-toggle="tab" data-bs-target="#institution" type="button" role="tab">
                        <i class="bi bi-building-gear me-1"></i>Institution Overall
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="department-tab" data-bs-toggle="tab" data-bs-target="#department" type="button" role="tab">
                        <i class="bi bi-diagram-3 me-1"></i>Department Results
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="faculty-tab" data-bs-toggle="tab" data-bs-target="#faculty" type="button" role="tab">
                        <i class="bi bi-person-badge me-1"></i>Faculty Results
                    </button>
                </li>
            </ul>
            
            <div class="tab-content" id="analyticsTabsContent">
                
                <!-- Institution Overall Tab -->
                <div class="tab-pane fade show active" id="institution" role="tabpanel">
                    <!-- Institution Filters -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="m-0"><i class="bi bi-funnel me-2"></i>Institution Filters</h5>
                            <div class="d-flex align-items-center gap-2">
                               
                                <button id="manualRefreshInstitution" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                                <span id="lastUpdatedInstitution" class="small text-muted"></span>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row g-3 filter-form">
                                <div class="col-md-8"> 
                                    <label class="form-label">Evaluation Cycle</label>
                                    <div class="search-container">
                                        <i class="bi bi-search search-icon"></i>
                                        <asp:TextBox ID="txtInstitutionCycle" runat="server" CssClass="form-control search-input" 
                                            placeholder="Type to search cycles..." />
                                        <asp:HiddenField ID="hfInstitutionCycleID" runat="server" Value="0" />
                                        <button type="button" class="search-clear" onclick="clearInstitutionCycleSearch()">
                                           
                                        </button>
                                        <div id="institutionCycleSuggestions" class="autocomplete-suggestions"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI Cards -->
                    <div class="row mb-4" id="institutionKpiSection">
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card kpi-card faculty h-100">
                                <div class="card-body">
                                    <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                        Faculty Evaluated
                                    </div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800" id="kpiFacultyEvaluated">-</div>
                                    <div class="mt-2 text-xs">
                                        <span id="kpiFacultyPending">- pending</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                       <div class="col-xl-3 col-md-6 mb-4">
    <div class="card kpi-card classes h-100">
        <div class="card-body">
            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                Classes Evaluated
            </div>
            <div class="h5 mb-0 font-weight-bold text-gray-800" id="kpiSubjectsEvaluated">-</div>
            <div class="mt-2 text-xs">
                <span id="kpiSubjectsOffered">- total classes</span>
            </div>
        </div>
    </div>
</div>

                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card kpi-card participation h-100">
                                <div class="card-body">
                                    <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                        Student Participation
                                    </div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800" id="kpiParticipationRate">-</div>
                                    <div class="mt-2 text-xs">
                                        <span id="kpiParticipationCount">- students</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card kpi-card average h-100">
                                <div class="card-body">
                                    <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                        Institution Average
                                    </div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800" id="kpiInstitutionAverage">-</div>
                                </div>
                            </div>
                        </div>
                    </div>

                   <!-- Domain Performance & Trend Charts -->
<div class="row mb-4">
    <div class="col-lg-6">
        <div class="card h-100">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="m-0"><i class="bi bi-bar-chart me-2"></i>Domain Performance</h5>
            </div>
            <div class="card-body">
                <div class="chart-container">
                    <canvas id="domainBarChart"></canvas>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card h-100">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="m-0"><i class="bi bi-graph-up me-2"></i>Trend Analysis</h5>
            </div>
            <div class="card-body">
                <div class="chart-container">
                    <canvas id="trendChart"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
                <!-- Department Results Tab -->
                <div class="tab-pane fade" id="department" role="tabpanel">
                    <!-- Department Filters -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="m-0"><i class="bi bi-funnel me-2"></i>Department Filters</h5>
                            <div class="d-flex align-items-center gap-2">
                                <button id="manualRefreshDepartment" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                                <span id="lastUpdatedDepartment" class="small text-muted"></span>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row g-3 filter-form">
                                <div class="col-md-4">
                                    <label class="form-label">Evaluation Cycle</label>
                                    <div class="search-container">
                                        <i class="bi bi-search search-icon"></i>
                                        <asp:TextBox ID="txtDepartmentCycle" runat="server" CssClass="form-control search-input" 
                                            placeholder="Type to search cycles..." />
                                        <asp:HiddenField ID="hfDepartmentCycleID" runat="server" Value="0" />
                                        <button type="button" class="search-clear" onclick="clearDepartmentCycleSearch()">
                                           
                                        </button>
                                        <div id="departmentCycleSuggestions" class="autocomplete-suggestions"></div>
                                    </div>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label">Department</label>
                                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-control" 
                                        DataTextField="DepartmentName" DataValueField="DepartmentID" AppendDataBoundItems="true">
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Department Comparison Chart -->
                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="m-0"><i class="bi bi-radar me-2"></i>Department Domain Comparison</h5>
                                </div>
                                <div class="card-body">
                                    <div class="radar-chart-container">
                                        <canvas id="departmentRadarChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                   

                    <!-- Department Performance Table -->
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="m-0"><i class="bi bi-table me-2"></i>Department Performance Details</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-hover" id="departmentTable">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>Department</th>
                                                    <th>Overall Score</th>
                                                    <th>Faculty Count</th>
                                                    <th>Evaluations</th>
                                                    <th>Status</th>
                                                    <th>Action</th>
                                                </tr>
                                            </thead>
                                            <tbody id="departmentTableBody">
                                                <tr>
                                                    <td colspan="6" class="text-center py-4">
                                                        <div class="loading-spinner"></div>
                                                        <p class="mt-2">Loading department data...</p>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Faculty Results Tab -->
                <div class="tab-pane fade" id="faculty" role="tabpanel">
                    <!-- Faculty Filters -->
                    <div class="card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="m-0"><i class="bi bi-funnel me-2"></i>Faculty Filters</h5>
                            <div class="d-flex align-items-center gap-2">
                                <button id="manualRefreshFaculty" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                                <span id="lastUpdatedFaculty" class="small text-muted"></span>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row g-3 filter-form">
                                <div class="col-md-3">
                                    <label class="form-label">Evaluation Cycle</label>
                                    <div class="search-container">
                                        <i class="bi bi-search search-icon"></i>
                                        <asp:TextBox ID="txtFacultyCycle" runat="server" CssClass="form-control search-input" 
                                            placeholder="Type to search cycles..." />
                                        <asp:HiddenField ID="hfFacultyCycleID" runat="server" Value="0" />
                                        <button type="button" class="search-clear" onclick="clearFacultyCycleSearch()">
                                      
                                        </button>
                                        <div id="facultyCycleSuggestions" class="autocomplete-suggestions"></div>
                                    </div>
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label">Department</label>
                                    <asp:DropDownList ID="ddlFacultyDepartment" runat="server" CssClass="form-control" 
                                        DataTextField="DepartmentName" DataValueField="DepartmentID" AppendDataBoundItems="true">
                                    </asp:DropDownList>
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label">Faculty Member</label>
                                    <div class="search-container">
                                        <i class="bi bi-search search-icon"></i>
                                        <asp:TextBox ID="txtFacultyMember" runat="server" CssClass="form-control search-input" 
                                            placeholder="Type to search faculty..." />
                                        <asp:HiddenField ID="hfFacultyMemberID" runat="server" Value="0" />
                                        <button type="button" class="search-clear" onclick="clearFacultyMemberSearch()">
                                            <i class="bi bi-x"></i>
                                        </button>
                                        <div id="facultyMemberSuggestions" class="autocomplete-suggestions"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Faculty List Table -->
                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center">
                                    <h5 class="m-0"><i class="bi bi-people me-2"></i>Faculty List</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-hover" id="facultyListTable">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>Faculty Name</th>
                                                    <th>Department</th>
                                                    <th>Overall Score</th>
                                                    <th>Subjects Count</th>
                                                    <th>Evaluations</th>
                                                    <th>Status</th>
                                                    <th>Action</th>
                                                </tr>
                                            </thead>
                                            <tbody id="facultyListTableBody">
                                                <tr>
                                                    <td colspan="7" class="text-center py-4">
                                                        <div class="loading-spinner"></div>
                                                        <p class="mt-2">Loading faculty data...</p>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

     <!-- Faculty Details Modal - SIMPLIFIED -->
<div class="modal fade" id="facultyDetailsModal" tabindex="-1" aria-labelledby="facultyDetailsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="facultyDetailsModalLabel">Faculty Analysis</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0">Subjects</h6>
                            </div>
                            <div class="card-body">
                                <div id="facultySubjectsDepartmentsList" style="max-height: 400px; overflow-y: auto;">
                                    <div class="text-center">
                                        <div class="spinner-border"></div>
                                        <p>Loading subjects...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h6 class="mb-0">Performance Summary</h6>
                                <span id="selectedSubjectTitle" class="badge bg-primary">All Subjects</span>
                            </div>
                            <div class="card-body">
                                <div class="row text-center mb-3">
                                    <div class="col-md-4">
                                        <h3 class="faculty-score score-excellent" id="modalOverallScore">0%</h3>
                                        <p class="text-muted">Overall Score</p>
                                    </div>
                                    <div class="col-md-4">
                                        <h3 id="modalSubjectsCount">0</h3>
                                        <p class="text-muted">Subjects</p>
                                    </div>
                                    <div class="col-md-4">
                                        <h3 id="modalEvaluationsCount">0</h3>
                                        <p class="text-muted">Evaluations</p>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <h6>Domain Performance</h6>
                                    <div class="chart-container">
                                        <canvas id="facultyDetailsDomainChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row mt-4">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h6 class="mb-0">Question Breakdown</h6>
                <small class="text-muted">All domain questions displayed below</small>
            </div>
            <div class="card-body p-0">
                <div id="questionBreakdownAccordion" style="max-height: 500px; overflow-y: auto;">
                    <div class="text-center py-4">
                        <div class="spinner-border text-primary"></div>
                        <p class="mt-2">Loading question breakdown...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
                
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0">Student Comments</h6>
                            </div>
                            <div class="card-body">
                                <div id="facultyDetailsComments">
                                    <div class="text-center">
                                        <div class="spinner-border"></div>
                                        <p>Loading comments...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

        <!-- Department Course Contribution Modal -->
        <div class="modal fade" id="departmentCourseModal" tabindex="-1" aria-labelledby="departmentCourseModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="departmentCourseModalLabel">Course Contribution - <span id="deptCourseModalName"></span></h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <!-- Department Overview -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <div class="card text-center">
                                    <div class="card-body">
                                        <h3 class="faculty-score score-excellent" id="deptCourseOverallScore">0%</h3>
                                        <p class="card-text">Department Overall Score</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card text-center">
                                    <div class="card-body">
                                        <h3 class="card-title" id="deptCourseCount">0</h3>
                                        <p class="card-text">Total Courses</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Domain Performance Chart -->
                        <div class="row mb-4">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header d-flex justify-content-between align-items-center">
                                        <h6>Domain Performance - <span id="domainChartTitle">All Courses</span></h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="chart-container" style="height: 400px; position: relative;">
                                            <canvas id="domainPerformanceChart"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Courses Contribution Table -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h6>Courses Performance Details</h6>
                                        <small class="text-muted">Click on a course to view its domain performance</small>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table table-hover" id="courseContributionTable">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th>Course Name</th>
                                                        <th>Average Score</th>
                                                        <th>Faculty Count</th>
                                                        <th>Evaluations</th>
                                                        <th>Subjects</th>
                                                        <th>Contribution %</th>                                                      
                                                    </tr>
                                                </thead>
                                                <tbody id="courseContributionBody">
                                                    <tr>
                                                        <td colspan="7" class="text-center py-4">
                                                            <div class="spinner-border"></div>
                                                            <p class="mt-2">Loading course data...</p>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script type="text/javascript">
        let domainBarChart = null;
        let trendChart = null;
        let departmentRadarChart = null;
        let facultyDetailsDomainChart = null;
        let currentFacultyId = 0;
        let currentSubjectId = 0;
        let currentDepartmentId = 0;
        let currentCourseId = 0;

        // Track if charts have been initialized
        let chartsInitialized = false;

        $(document).ready(function () {
            initializePage();
        });


        function initializePage() {
            initializeEventHandlers();
            initializeAutocomplete();

            // Set default cycle and load data
            setDefaultCycle();

            // Load institution data immediately since it's the default active tab
            loadInstitutionData();

            // Set up tab change handlers for other tabs
            $('#department-tab').on('click', function () {
                loadDepartmentData();
            });

            $('#faculty-tab').on('click', function () {
                loadFacultyData();
            });
        }

        // Initialize event handlers
        function initializeEventHandlers() {
            // Tab change handlers - KEEP ONLY ONE for each tab
            $('#institution-tab').on('click', function () {
                loadInstitutionData();
            });

            $('#department-tab').on('click', function () {
                loadDepartmentData();
            });

            $('#faculty-tab').on('click', function () {
                loadFacultyData();
            });

            // Manual refresh buttons
            $('#manualRefreshInstitution').click(function (e) {
                e.preventDefault();
                loadInstitutionData();
                animateRefreshButton(this);
            });

            $('#manualRefreshDepartment').click(function (e) {
                e.preventDefault();
                loadDepartmentData();
                animateRefreshButton(this);
            });

            $('#manualRefreshFaculty').click(function (e) {
                e.preventDefault();
                loadFacultyData();
                animateRefreshButton(this);
            });

            // Department dropdown change
            $('#<%= ddlDepartment.ClientID %>').change(function () {
                loadDepartmentData();
            });

            // Faculty dropdown change
            $('#<%= ddlFacultyDepartment.ClientID %>').change(function () {
                loadFacultyData();
            });

        }

        // Initialize autocomplete functionality
        function initializeAutocomplete() {
            initializeCycleAutocomplete('#<%= txtInstitutionCycle.ClientID %>', '#<%= hfInstitutionCycleID.ClientID %>', '#institutionCycleSuggestions');
            initializeCycleAutocomplete('#<%= txtDepartmentCycle.ClientID %>', '#<%= hfDepartmentCycleID.ClientID %>', '#departmentCycleSuggestions');
            initializeCycleAutocomplete('#<%= txtFacultyCycle.ClientID %>', '#<%= hfFacultyCycleID.ClientID %>', '#facultyCycleSuggestions');
            initializeFacultyAutocomplete();
        }

        // Initialize cycle autocomplete
        function initializeCycleAutocomplete(inputSelector, hiddenSelector, suggestionsSelector) {
            $(inputSelector).on('input', function () {
                const searchTerm = $(this).val();
                if (searchTerm.length < 2) {
                    $(suggestionsSelector).hide();
                    return;
                }

                PageMethods.SearchAllData(searchTerm, function (response) {
                    try {
                        const suggestions = JSON.parse(response);
                        const cycleSuggestions = suggestions.filter(s => s.Type === 'Cycle');
                        displaySuggestions(cycleSuggestions, suggestionsSelector, inputSelector, hiddenSelector);
                    } catch (e) {
                        console.error('Error parsing cycle suggestions:', e);
                    }
                }, function (error) {
                    console.error('Error fetching cycle suggestions:', error);
                });
            });

            // Set default cycle text on page load
            setTimeout(() => {
                if ($(inputSelector).val() === '') {
                    // This will be set by the code-behind, but as a fallback:
                    loadDefaultCycle(inputSelector, hiddenSelector);
                }
            }, 500);

            // Hide suggestions when clicking outside
            $(document).on('click', function (e) {
                if (!$(e.target).closest(suggestionsSelector).length && !$(e.target).is(inputSelector)) {
                    $(suggestionsSelector).hide();
                }
            });
        }

        // Fallback function to load default cycle
        function loadDefaultCycle(inputSelector, hiddenSelector) {
            // You could also call a WebMethod here to get the default cycle
            // For now, we rely on the code-behind to set the values
            console.log("Checking default cycle for:", inputSelector);
        }

        // Initialize faculty autocomplete
        function initializeFacultyAutocomplete() {
            $('#<%= txtFacultyMember.ClientID %>').on('input', function () {
                const searchTerm = $(this).val();
                if (searchTerm.length < 2) {
                    $('#facultyMemberSuggestions').hide();
                    return;
                }

                PageMethods.SearchAllData(searchTerm, function (response) {
                    try {
                        const suggestions = JSON.parse(response);
                        const facultySuggestions = suggestions.filter(s => s.Type === 'Faculty');
                        displaySuggestions(facultySuggestions, '#facultyMemberSuggestions', '#<%= txtFacultyMember.ClientID %>', '#<%= hfFacultyMemberID.ClientID %>');
                    } catch (e) {
                        console.error('Error parsing faculty suggestions:', e);
                    }
                }, function (error) {
                    console.error('Error fetching faculty suggestions:', error);
                });
            });
        }

        // Display autocomplete suggestions
        function displaySuggestions(suggestions, containerSelector, inputSelector, hiddenSelector) {
            const container = $(containerSelector);
            if (!suggestions || suggestions.length === 0) {
                container.hide();
                return;
            }

            let html = '';
            suggestions.forEach(suggestion => {
                // For cycles, format the secondary text to highlight dates
                let secondaryText = suggestion.SecondaryText;
                if (suggestion.Type === 'Cycle') {
                    // You can add additional formatting here if needed
                    secondaryText = `<div class="cycle-dates">${secondaryText}</div>`;
                }

                html += `
        <div class="suggestion-item" data-id="${suggestion.ID}">
            <div class="suggestion-primary">${escapeHtml(suggestion.PrimaryText)}</div>
            <div class="suggestion-secondary">${secondaryText}</div>
        </div>
    `;
            });

            container.html(html).show();

            // Handle suggestion click
            container.find('.suggestion-item').click(function () {
                const id = $(this).data('id');
                const text = $(this).find('.suggestion-primary').text();
                $(inputSelector).val(text);
                $(hiddenSelector).val(id);
                container.hide();

                // Trigger data load based on current tab
                const activeTab = $('.nav-tabs .nav-link.active').attr('id');
                if (activeTab === 'institution-tab') loadInstitutionData();
                else if (activeTab === 'department-tab') loadDepartmentData();
                else if (activeTab === 'faculty-tab') loadFacultyData();
            });
        }

        // Load institution data
        function loadInstitutionData() {
            let cycleId = $('#<%= hfInstitutionCycleID.ClientID %>').val() || '0';

            // Convert "Overall" (-1) to empty string for server-side processing
            if (cycleId === '-1') {
                cycleId = '';
            }

            $('#manualRefreshInstitution').prop('disabled', true);
            showLoadingState('#institutionKpiSection', 'Loading institution data...');

            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetInstitutionData",
                data: JSON.stringify({
                    cycleId: cycleId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response && response.d) {
                        try {
                            const data = JSON.parse(response.d);
                            updateInstitutionTab(data);
                            removeLoadingState('#institutionKpiSection');
                            $('#lastUpdatedInstitution').text('Last updated: ' + new Date().toLocaleTimeString());
                        } catch (e) {
                            console.error("Error parsing institution data:", e);
                            showMessage("Error loading institution data", "danger");
                        }
                    } else {
                        showMessage("No data returned from server", "warning");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    showMessage("Failed to load institution data", "danger");
                    removeLoadingState('#institutionKpiSection');
                },
                complete: function () {
                    $('#manualRefreshInstitution').prop('disabled', false);
                }
            });
        }

        function removeLoadingState(selector) {
            if (selector === '#institutionKpiSection') {
                $(selector).find('.loading-overlay').remove();
            }
            // For other selectors, the content will be replaced by actual data
        }

        // Load department data
        function loadDepartmentData() {
            let cycleId = $('#<%= hfDepartmentCycleID.ClientID %>').val() || '0';
            const departmentId = $('#<%= ddlDepartment.ClientID %>').val() || '0';

            // Convert "Overall" (-1) to empty string for server-side processing
            if (cycleId === '-1') {
                cycleId = '';
            }

            $('#manualRefreshDepartment').prop('disabled', true);
            showLoadingState('#departmentTableBody', 'Loading department data...');

            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetDepartmentData",
                data: JSON.stringify({
                    cycleId: cycleId,
                    departmentId: departmentId,
                    courseId: '0'
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response && response.d) {
                        try {
                            const data = JSON.parse(response.d);
                            updateDepartmentTab(data);
                            $('#lastUpdatedDepartment').text('Last updated: ' + new Date().toLocaleTimeString());
                        } catch (e) {
                            console.error("Error parsing department data:", e);
                            showMessage("Error loading department data", "danger");
                        }
                    } else {
                        showMessage("No data returned from server", "warning");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    showMessage("Failed to load department data", "danger");
                },
                complete: function () {
                    $('#manualRefreshDepartment').prop('disabled', false);
                }
            });
        }

        // Load faculty data
        // Update loadFacultyData function to remove subject parameter
        function loadFacultyData() {
            let cycleId = $('#<%= hfFacultyCycleID.ClientID %>').val() || '0';
            const departmentId = $('#<%= ddlFacultyDepartment.ClientID %>').val() || '0';
            const facultyId = $('#<%= hfFacultyMemberID.ClientID %>').val() || '0';

            // Convert "Overall" (-1) to empty string for server-side processing
            if (cycleId === '-1') {
                cycleId = '';
            }

            console.log("Loading faculty data with params:", {
                cycleId: cycleId,
                departmentId: departmentId,
                facultyId: facultyId
            });

            $('#manualRefreshFaculty').prop('disabled', true);
            showLoadingState('#facultyListTableBody', 'Loading faculty data...');

            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetFacultyData",
                data: JSON.stringify({
                    cycleId: cycleId,
                    departmentId: departmentId,
                    courseId: '0',
                    facultyId: facultyId,
                    subjectId: '0'
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Faculty data response:", response);

                    if (response && response.d) {
                        try {
                            const data = JSON.parse(response.d);
                            console.log("Parsed faculty data:", data);
                            updateFacultyTab(data);
                            $('#lastUpdatedFaculty').text('Last updated: ' + new Date().toLocaleTimeString());
                        } catch (e) {
                            console.error("Error parsing faculty data:", e);
                            showMessage("Error loading faculty data: " + e.message, "danger");
                        }
                    } else {
                        console.warn("No data in faculty response");
                        showMessage("No data returned from server", "warning");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    console.error("Status:", status);
                    console.error("XHR:", xhr);
                    showMessage("Failed to load faculty data: " + error, "danger");
                },
                complete: function () {
                    $('#manualRefreshFaculty').prop('disabled', false);
                }
            });
        }



        // Update institution tab with data
        function updateInstitutionTab(data) {
            if (!data) {
                showMessage("No institution data available", "warning");
                return;
            }

            updateInstitutionKPIs(data.KPIs);
            updateDomainPerformance(data.DomainPerformance);
            updateTrendChart(data.TrendData);

        }

        // Update department tab with data
        function updateDepartmentTab(data) {
            if (!data) {
                showMessage("No department data available", "warning");
                return;
            }

            updateDepartmentComparison(data.Departments);
            updateTopBottomDomains(data.TopDomains, data.BottomDomains);
            updateDepartmentTable(data.Departments);
        }

        // Update faculty tab with data
        function updateFacultyTab(data) {
            if (!data) {
                showMessage("No faculty data available", "warning");
                return;
            }

            updateFacultyPerformance(data.FacultyPerformance);
            loadFacultyList();
        }
        // Update institution KPI cards
        // Update institution KPI cards with correct formatting
        function updateInstitutionKPIs(kpis) {
            if (!kpis) {
                kpis = {
                    FacultyEvaluated: 0,
                    FacultyPending: 0,
                    ClassesEvaluated: 0, // Updated
                    ClassesOffered: 0, // Updated
                    StudentParticipationRate: 0,
                    StudentsParticipated: 0,
                    TotalStudents: 0,
                    InstitutionAverage: 0
                };
            }

            $('#kpiFacultyEvaluated').text(kpis.FacultyEvaluated || 0);
            $('#kpiFacultyPending').text((kpis.FacultyPending || 0) + ' pending');
            $('#kpiSubjectsEvaluated').text(kpis.ClassesEvaluated || 0); // Updated ID but keeping for compatibility
            $('#kpiSubjectsOffered').text((kpis.ClassesOffered || 0) + ' offered'); // Updated ID but keeping for compatibility
            $('#kpiParticipationRate').text((kpis.StudentParticipationRate || 0).toFixed(1) + '%');
            $('#kpiParticipationCount').text((kpis.StudentsParticipated || 0) + ' of ' + (kpis.TotalStudents || 0) + ' students');
            $('#kpiInstitutionAverage').text((kpis.InstitutionAverage || 0).toFixed(1) + '%');
        }
        // Update domain performance with bar chart
        function updateDomainPerformance(domains) {
            const container = $('#domainBarChart').closest('.card-body');

            if (domainBarChart) {
                domainBarChart.destroy();
                domainBarChart = null;
            }

            if (!domains || domains.length === 0) {
                container.html('<div class="text-center py-4 text-muted">No domain data available</div>');
                return;
            }

            try {
                if (container.find('canvas').length === 0) {
                    container.html('<canvas id="domainBarChart"></canvas>');
                }

                const canvas = document.getElementById('domainBarChart');
                const ctx = canvas.getContext('2d');

                // Sort by raw score (highest performance first)
                domains.sort((a, b) => b.RawAverage - a.RawAverage);

                // Create labels that include weights
                const labels = domains.map(d => `${d.DomainName}\n(Weight: ${d.Weight}%)`);
                const rawScores = domains.map(d => d.RawAverage);

                domainBarChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Score (1-5)',
                            data: rawScores,
                            backgroundColor: rawScores.map(score => {
                                if (score >= 4.5) return 'rgba(40, 167, 69, 0.8)';
                                if (score >= 4.0) return 'rgba(23, 162, 184, 0.8)';
                                if (score >= 3.5) return 'rgba(255, 193, 7, 0.8)';
                                if (score >= 3.0) return 'rgba(253, 126, 20, 0.8)';
                                return 'rgba(220, 53, 69, 0.8)';
                            }),
                            borderColor: rawScores.map(score => {
                                if (score >= 4.5) return 'rgba(40, 167, 69, 1)';
                                if (score >= 4.0) return 'rgba(23, 162, 184, 1)';
                                if (score >= 3.5) return 'rgba(255, 193, 7, 1)';
                                if (score >= 3.0) return 'rgba(253, 126, 20, 1)';
                                return 'rgba(220, 53, 69, 1)';
                            }),
                            borderWidth: 2,
                            borderRadius: 4,
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                min: 0,
                                max: 5,
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                },
                                title: {
                                    display: true,
                                    text: 'Average Score (1-5 Scale)'
                                }
                            },
                            x: {
                                ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45,
                                    font: {
                                        size: 11
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
                                        // Show just the domain name in tooltip title
                                        const fullLabel = tooltipItems[0].label;
                                        return fullLabel.split('\n')[0];
                                    },
                                    label: function (context) {
                                        const domain = domains[context.dataIndex];
                                        const rawScore = context.raw.toFixed(2);
                                        const weightedScore = domain.AverageScore.toFixed(1);

                                        return [
                                            `Score: ${rawScore}/5`,
                                            `Weighted: ${weightedScore}% (Weight: ${domain.Weight}%)`,
                                            `Calculation: (${rawScore} ÷ 5) × ${domain.Weight} = ${weightedScore}%`
                                        ];
                                    }
                                }
                            }
                        }
                    }
                });

            } catch (e) {
                console.error("Error creating domain bar chart:", e);
                container.html('<div class="text-center py-4 text-muted">Error loading domain chart</div>');
            }
        }



        function updateTrendChart(trendData) {
            const container = $('#trendChart').closest('.card-body');

            // Clear existing chart
            if (trendChart) {
                trendChart.destroy();
                trendChart = null;
            }

            if (!trendData || trendData.length === 0) {
                container.html('<div class="text-center py-4 text-muted">No trend data available</div>');
                return;
            }

            try {
                // Ensure canvas exists
                if (container.find('canvas').length === 0) {
                    container.html('<canvas id="trendChart"></canvas>');
                }

                const canvas = document.getElementById('trendChart');
                const ctx = canvas.getContext('2d');

                trendChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: trendData.map(t => t.CycleName),
                        datasets: [{
                            label: 'Institution Average',
                            data: trendData.map(t => t.AverageScore),
                            borderColor: '#4e73df',
                            backgroundColor: 'rgba(78, 115, 223, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: false,
                                suggestedMin: 0,
                                suggestedMax: 100,
                                title: {
                                    display: true,
                                    text: 'Average Score (%)'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Evaluation Cycle'
                                }
                            }
                        }
                    }
                });

                // Force chart update
                setTimeout(() => {
                    if (trendChart) {
                        trendChart.update();
                    }
                }, 100);

            } catch (e) {
                console.error("Error creating trend chart:", e);
                container.html('<div class="text-center py-4 text-muted">Error loading trend chart</div>');
            }
        }




        // Update department comparison chart
        function updateDepartmentComparison(departments) {
            const canvas = document.getElementById('departmentRadarChart');
            if (!canvas) return;

            if (departmentRadarChart) {
                departmentRadarChart.destroy();
                departmentRadarChart = null;
            }

            if (!departments || departments.length === 0) {
                $('#departmentRadarChart').closest('.card-body').html('<div class="text-center py-4 text-muted">No department data available</div>');
                return;
            }

            try {
                const ctx = canvas.getContext('2d');

                const allDomains = [];
                departments.forEach(dept => {
                    if (dept.DomainScores) {
                        dept.DomainScores.forEach(domain => {
                            if (!allDomains.includes(domain.DomainName)) {
                                allDomains.push(domain.DomainName);
                            }
                        });
                    }
                });

                const colors = ['#4e73df', '#1cc88a', '#36b9cc', '#f6c23e', '#e74a3b', '#6f42c1'];

                const datasets = departments.map((dept, index) => {
                    const domainScores = allDomains.map(domainName => {
                        if (!dept.DomainScores) return 0;
                        const domainData = dept.DomainScores.find(d => d.DomainName === domainName);
                        if (domainData && domainData.RawScore !== undefined) {
                            return Math.min(Math.max(domainData.RawScore, 0), 5);
                        }
                        return 0;
                    });

                    return {
                        label: dept.DepartmentName,
                        data: domainScores,
                        backgroundColor: `rgba(${hexToRgb(colors[index % colors.length])}, 0.2)`,
                        borderColor: colors[index % colors.length],
                        borderWidth: 2,
                        pointBackgroundColor: colors[index % colors.length],
                        pointBorderColor: '#fff',
                        pointHoverBackgroundColor: '#fff',
                        pointHoverBorderColor: colors[index % colors.length],
                        pointRadius: 4,
                        pointHoverRadius: 6
                    };
                });

                departmentRadarChart = new Chart(ctx, {
                    type: 'radar',
                    data: {
                        labels: allDomains,
                        datasets: datasets
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            r: {
                                beginAtZero: true,
                                min: 0,
                                max: 5,
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value % 1 === 0 ? value.toString() : value.toFixed(1);
                                    }
                                },
                                pointLabels: {
                                    font: {
                                        size: 11,
                                        weight: '500'
                                    },
                                    color: '#495057'
                                },
                                angleLines: {
                                    color: 'rgba(0, 0, 0, 0.1)'
                                },
                                grid: {
                                    color: 'rgba(0, 0, 0, 0.1)'
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                position: 'top',
                                labels: {
                                    padding: 15,
                                    usePointStyle: true,
                                    font: {
                                        size: 12,
                                        weight: '500'
                                    }
                                }
                            },
                            tooltip: {
                                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                titleColor: '#495057',
                                bodyColor: '#495057',
                                borderColor: '#dee2e6',
                                borderWidth: 1,
                                callbacks: {
                                    label: function (context) {
                                        const departmentName = context.dataset.label;
                                        const domainName = context.label;
                                        const rawScore = context.raw.toFixed(2);
                                        const department = departments.find(dept => dept.DepartmentName === departmentName);

                                        let tooltipLines = [
                                            `${departmentName}`,
                                            `${domainName}: ${rawScore}/5`
                                        ];

                                        if (department && department.DomainScores) {
                                            const domainData = department.DomainScores.find(d => d.DomainName === domainName);
                                            if (domainData) {
                                                const weightedScore = domainData.Score ? domainData.Score.toFixed(1) : '0.0';
                                                const weight = domainData.Weight || 0;
                                                tooltipLines.push(`Weighted: ${weightedScore}%`);
                                                tooltipLines.push(`Domain Weight: ${weight}%`);
                                                tooltipLines.push(`Calculation: (${rawScore} ÷ 5) × ${weight} = ${weightedScore}%`);
                                            }
                                        }

                                        return tooltipLines;
                                    }
                                }
                            }
                        },
                        elements: {
                            line: {
                                tension: 0.1
                            }
                        }
                    }
                });
            } catch (e) {
                console.error("Error creating department radar chart:", e);
                $('#departmentRadarChart').closest('.card-body').html('<div class="text-center py-4 text-muted">Error loading department comparison</div>');
            }
        }

        // Update top and bottom domains
        function updateTopBottomDomains(topDomains, bottomDomains) {
            updateDomainList(topDomains, '#topDomainsList', 'success');
            updateDomainList(bottomDomains, '#bottomDomainsList', 'danger');
        }

        function updateDomainList(domains, containerSelector, badgeClass) {
            const container = $(containerSelector);
            if (!domains || domains.length === 0) {
                container.html('<div class="text-center py-2 text-muted">No data available</div>');
                return;
            }

            let html = '';
            domains.forEach((domain, index) => {
                html += `
            <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                <div>
                    <span class="badge bg-${badgeClass} me-2">${index + 1}</span>
                    <strong>${escapeHtml(domain.DomainName)}</strong>
                </div>
                <span class="fw-bold" style="color: ${getScoreColor(domain.Score)}">${domain.Score}%</span>
            </div>
        `;
            });

            container.html(html);
        }
        // Update department table
        function updateDepartmentTable(departments) {
            const tbody = $('#departmentTableBody');
            if (!departments || departments.length === 0) {
                tbody.html('<tr><td colspan="6" class="text-center py-4 text-muted">No department data available</td></tr>');
                return;
            }

            let html = '';
            departments.forEach(dept => {
                const statusClass = getScoreStatusClass(dept.OverallScore);
                const statusText = getScoreStatusText(dept.OverallScore);

                html += `
            <tr>
                <td class="fw-bold">${escapeHtml(dept.DepartmentName)}</td>
                <td>
                    <span class="faculty-score ${statusClass}">${dept.OverallScore || 0}%</span>
                </td>
                <td>${dept.FacultyCount || 0}</td>
                <td>${dept.EvaluationCount || 0}</td>
                <td><span class="badge bg-${statusClass}">${statusText}</span></td>
                <td>
                     <button type="button" class="btn btn-action-secondary btn-sm"
            onclick="showDepartmentCourseContribution(${dept.DepartmentID}, '${escapeHtml(dept.DepartmentName)}')">
        <i class="bi bi-pie-chart"></i> View Courses
    </button>
                </td>
            </tr>
        `;
            });

            tbody.html(html);
        }

        // Update faculty performance
        function updateFacultyPerformance(performance) {
            if (!performance) {
                performance = {
                    OverallScore: 0,
                    SubjectsCount: 0,
                    EvaluationsCount: 0
                };
            }

            $('#facultyOverallScore').text(performance.OverallScore + '%').attr('class', 'card-title faculty-score ' + getScoreStatusClass(performance.OverallScore));
            $('#facultySubjectsCount').text(performance.SubjectsCount || 0);
            $('#facultyEvaluationsCount').text(performance.EvaluationsCount || 0);
        }

        function updateFacultyModalPerformance(performance) {
            if (!performance) {
                performance = {
                    OverallScore: 0,
                    RawOverallScore: 0,
                    SubjectsCount: 0,
                    EvaluationsCount: 0
                };
            }

            // Display ONLY weighted score (percentage) - remove raw score display
            $('#modalOverallScore').text((performance.OverallScore || 0).toFixed(1) + '%')
                .attr('class', 'faculty-score ' + getScoreStatusClass(performance.OverallScore));

            // Remove any existing weighted score display to avoid duplication
            $('#weightedScoreDisplay').remove();

            $('#modalSubjectsCount').text(performance.SubjectsCount || 0);
            $('#modalEvaluationsCount').text(performance.EvaluationsCount || 0);
        }


        function loadFacultyList() {
            const cycleId = $('#<%= hfFacultyCycleID.ClientID %>').val() || '0';
            const departmentId = $('#<%= ddlFacultyDepartment.ClientID %>').val() || '0';

            console.log("Loading faculty list with params:", {
                cycleId: cycleId,
                departmentId: departmentId
            });

            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetFacultyList",
                data: JSON.stringify({
                    cycleId: cycleId,
                    departmentId: departmentId,
                    courseId: '0'
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Faculty list response:", response);

                    if (response && response.d) {
                        try {
                            const facultyList = JSON.parse(response.d);
                            console.log("Parsed faculty list:", facultyList);
                            updateFacultyListTable(facultyList);
                        } catch (e) {
                            console.error("Error parsing faculty list data:", e);
                            showMessage("Error loading faculty list data: " + e.message, "danger");
                        }
                    } else {
                        console.warn("No data in faculty list response");
                        showMessage("No faculty data returned from server", "warning");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error in faculty list:", error);
                    console.error("Status:", status);
                    showMessage("Failed to load faculty list data: " + error, "danger");
                }
            });
        }

        // Update faculty list table
        function updateFacultyListTable(facultyList) {
            const tbody = $('#facultyListTableBody');
            console.log("Updating faculty list table with data:", facultyList);

            if (!facultyList || facultyList.length === 0) {
                console.warn("No faculty data available");
                tbody.html('<tr><td colspan="7" class="text-center py-4 text-muted">No faculty data available</td></tr>');
                return;
            }

            let html = '';
            let hasData = false;

            facultyList.forEach(faculty => {
                // Check if we have valid faculty data
                if (faculty && faculty.FacultyName) {
                    hasData = true;
                    const statusClass = getScoreStatusClass(faculty.OverallScore || 0);
                    const statusText = getScoreStatusText(faculty.OverallScore || 0);
                    const weightedScore = faculty.OverallScore || 0;

                    html += `
                <tr>
                    <td class="fw-bold">${escapeHtml(faculty.FacultyName)}</td>
                    <td>${escapeHtml(faculty.DepartmentName || 'N/A')}</td>
                    <td>
                        <span class="faculty-score ${statusClass}">${weightedScore.toFixed(1)}%</span>
                    </td>
                    <td>${faculty.SubjectsCount || 0}</td>
                    <td>${faculty.EvaluationsCount || 0}</td>
                    <td><span class="badge bg-${statusClass}">${statusText}</span></td>
                    <td>
                        <button type="button" class="btn btn-action-primary btn-sm"
            onclick="showFacultyDetails(${faculty.FacultyID}, '${escapeHtml(faculty.FacultyName)}')">
        <i class="bi bi-eye"></i> View Details
    </button>
                    </td>
                </tr>`;
                }
            });

            if (!hasData) {
                console.warn("No valid faculty data found in the list");
                tbody.html('<tr><td colspan="7" class="text-center py-4 text-muted">No valid faculty data available</td></tr>');
            } else {
                tbody.html(html);
                console.log(`Displayed ${facultyList.length} faculty members`);
            }
        }
        // Show faculty details modal - FIXED VERSION
        function showFacultyDetails(facultyId, facultyName) {
            currentFacultyId = facultyId;
            currentSubjectId = 0;

            // Show loading state
            $('#facultyDetailsModalLabel').text(`Faculty Analysis - ${facultyName}`);
            $('#selectedSubjectTitle').text('All Subjects');
            $('#facultySubjectsDepartmentsList').html('<div class="text-center"><div class="spinner-border text-primary"></div><p>Loading subjects...</p></div>');
            $('#modalOverallScore').text('0%');
            $('#modalSubjectsCount').text('0');
            $('#modalEvaluationsCount').text('0');
            $('#questionBreakdownAccordion').html('<div class="text-center"><div class="spinner-border text-primary"></div><p>Loading question breakdown...</p></div>');
            $('#facultyDetailsComments').html('<div class="text-center"><div class="spinner-border text-primary"></div><p>Loading comments...</p></div>');

            const cycleId = $('#<%= hfFacultyCycleID.ClientID %>').val() || '0';
            const departmentId = $('#<%= ddlFacultyDepartment.ClientID %>').val() || '0';

           // Load faculty data for the modal
           $.ajax({
               type: "POST",
               url: "Reports.aspx/GetFacultyData",
               data: JSON.stringify({
                   cycleId: cycleId,
                   departmentId: departmentId,
                   courseId: '0',
                   facultyId: facultyId,
                   subjectId: '0'
               }),
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (response) {
                   if (response && response.d) {
                       try {
                           const facultyData = JSON.parse(response.d);

                           // Populate subjects list
                           populateFacultySubjectsList(facultyData.SubjectResults, facultyId, facultyName);

                           // Update performance metrics
                           updateFacultyModalPerformance(facultyData.FacultyPerformance);

                           // Initialize and update domain chart
                           initializeChartContainer();
                           updateFacultyDetailsDomainChart(facultyData.DomainScores);

                           // Load question breakdown
                           loadQuestionBreakdownForSubject(cycleId, facultyId, 0, departmentId, 0);

                           // Display comments
                           displayFacultyDetailsComments(facultyData.Comments);

                           // Show modal
                           $('#facultyDetailsModal').modal('show');

                       } catch (e) {
                           console.error("Error parsing faculty data:", e);
                           showMessage("Error loading faculty data: " + e.message, "danger");
                       }
                   } else {
                       showMessage("No faculty data returned from server", "warning");
                   }
               },
               error: function (xhr, status, error) {
                   console.error("AJAX error:", error);
                   showMessage("Failed to load faculty data: " + error, "danger");
               }
           });
       }

        // Updated populateFacultySubjectsList function - hides department name
        function populateFacultySubjectsList(subjectResults, facultyId, facultyName) {
            const container = $('#facultySubjectsDepartmentsList');

            // Filter out subjects with no evaluations or zero evaluation count
            const evaluatedSubjects = subjectResults.filter(subject =>
                subject.EvaluationCount > 0 && subject.AverageScore > 0
            );

            if (!evaluatedSubjects || evaluatedSubjects.length === 0) {
                container.html(`
            <div class="text-center text-muted py-4">
                <i class="bi bi-clipboard-x" style="font-size: 2rem;"></i>
                <p class="mt-2">No evaluated subjects found</p>
                <small>This faculty has no evaluation data for the selected criteria</small>
            </div>
        `);
                return;
            }

            let html = '';

            // Add "All Evaluated Subjects" option
            html += `
        <div class="subject-item p-2 mb-2 border rounded cursor-pointer active-subject bg-light"
             onclick="loadFacultySubjectData(${facultyId}, '${escapeHtml(facultyName)}', 0, 'All Evaluated Subjects', 0, 0)">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <strong class="text-primary">All Evaluated Subjects</strong>
                    <div class="small text-muted">Combined performance across ${evaluatedSubjects.length} evaluated subjects</div>
                </div>
                <div class="text-primary">
                    <i class="bi bi-arrow-right"></i>
                </div>
            </div>
        </div>
    `;

            // Group by course for organization (removed department grouping)
            const courseGroups = {};

            evaluatedSubjects.forEach(subject => {
                const courseName = subject.CourseName || 'General Course';
                const courseKey = courseName;

                if (!courseGroups[courseKey]) {
                    courseGroups[courseKey] = {
                        courseName: courseName,
                        subjects: []
                    };
                }

                courseGroups[courseKey].subjects.push(subject);
            });

            // Create simplified HTML structure without department grouping
            Object.values(courseGroups).forEach(courseGroup => {
                courseGroup.subjects.forEach(subject => {
                    const statusClass = getScoreStatusClass(subject.AverageScore);
                    const uniqueKey = `${subject.SubjectID}_${subject.DepartmentID || 0}_${subject.CourseID || 0}`;

                    html += `
                <div class="subject-item p-2 mb-1 border rounded cursor-pointer"
                     onclick="loadFacultySubjectData(
                         ${facultyId}, 
                         '${escapeHtml(facultyName)}', 
                         ${subject.SubjectID || 0}, 
                         '${escapeHtml(subject.SubjectName)}', 
                         ${subject.DepartmentID || 0}, 
                         ${subject.CourseID || 0}
                     )">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="flex-grow-1">
                            <strong class="subject-name d-block">${escapeHtml(subject.SubjectName)}</strong>
                            <!-- REMOVED DEPARTMENT NAME - Only show course name -->
                            <small class="text-muted">
                                ${escapeHtml(courseGroup.courseName)}
                            </small>
                        </div>
                        <div class="text-end ms-2">
                            <span class="badge bg-${statusClass}">${(subject.AverageScore || 0).toFixed(1)}%</span>
                            <div class="small text-muted mt-1">${subject.EvaluationCount || 0} eval(s)</div>
                        </div>
                    </div>
                </div>
            `;
                });
            });

            container.html(html);

            // Update the modal to show count of evaluated subjects
            $('#modalSubjectsCount').text(evaluatedSubjects.length);
        }
        // Load data for specific subject in faculty modal - FIXED VERSION
        function loadFacultySubjectData(facultyId, facultyName, subjectId, subjectName, departmentId, courseId) {
            currentSubjectId = subjectId;

            const cycleId = $('#<%= hfFacultyCycleID.ClientID %>').val() || '0';

          // Update UI
          if (subjectId === 0) {
              $('#selectedSubjectTitle').text('All Evaluated Subjects');
          } else {
              $('#selectedSubjectTitle').text(subjectName);
          }

          // Show loading states
          showLoadingOverlay('#facultyDetailsDomainChart');
          $('#questionBreakdownAccordion').html('<div class="text-center"><div class="spinner-border text-primary"></div><p>Loading question breakdown...</p></div>');
          $('#facultyDetailsComments').html('<div class="text-center"><div class="spinner-border text-primary"></div><p>Loading comments...</p></div>');

          // Highlight selected subject
          $('.subject-item').removeClass('active-subject border-primary bg-light');
          if (subjectId === 0) {
              $('.subject-item').first().addClass('active-subject border-primary bg-light');
          } else {
              // Find and highlight the specific subject
              $(`.subject-item:contains('${subjectName}')`).addClass('active-subject border-primary bg-light');
          }

          // Load data
          loadFacultyModalData(cycleId, facultyId, subjectId, departmentId, courseId);
      }


        // Helper function to show loading overlay without destroying chart
        function showLoadingOverlay(chartSelector) {
            const container = $(chartSelector).closest('.chart-container');
            // Remove existing overlay if any
            container.find('.chart-loading-overlay').remove();
            // Add loading overlay
            container.append(`
        <div class="chart-loading-overlay" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.8); display: flex; align-items: center; justify-content: center; z-index: 5;">
            <div class="text-center">
                <div class="spinner-border text-primary"></div>
                <p class="mt-2 text-muted">Loading domain performance...</p>
            </div>
        </div>
    `);
        }

        // Helper function to remove loading overlay
        function hideLoadingOverlay(chartSelector) {
            const container = $(chartSelector).closest('.chart-container');
            container.find('.chart-loading-overlay').remove();
        }
        
        // Load all modal data for a specific subject with context - IMPROVED VERSION
        function loadFacultyModalData(cycleId, facultyId, subjectId, departmentId, courseId) {
            console.log("=== loadFacultyModalData ===", {
                facultyId: facultyId,
                subjectId: subjectId,
                departmentId: departmentId,
                courseId: courseId,
                cycleId: cycleId
            });

            // Convert "Overall" (-1) to empty string for server-side processing
            if (cycleId === '-1') {
                cycleId = '';
            }

            // Show loading states
            $('#modalOverallScore').text('Loading...');
            $('#modalSubjectsCount').text('Loading...');
            $('#modalEvaluationsCount').text('Loading...');

            // Load faculty data with proper context
            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetFacultyData",
                data: JSON.stringify({
                    cycleId: cycleId,
                    departmentId: departmentId,
                    courseId: courseId,
                    facultyId: facultyId,
                    subjectId: subjectId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Faculty data response:", response);

                    if (response && response.d) {
                        try {
                            const facultyData = JSON.parse(response.d);
                            console.log("Parsed faculty data:", facultyData);

                            // Update performance metrics
                            updateFacultyModalPerformance(facultyData.FacultyPerformance);

                            // Remove loading overlay and update domain chart
                            hideLoadingOverlay('#facultyDetailsDomainChart');
                            if (facultyData.DomainScores && facultyData.DomainScores.length > 0) {
                                updateFacultyDetailsDomainChart(facultyData.DomainScores);
                            } else {
                                $('#facultyDetailsDomainChart').closest('.chart-container').html(
                                    '<div class="text-center py-4 text-muted">' +
                                    '<i class="bi bi-bar-chart" style="font-size: 2rem;"></i>' +
                                    '<p class="mt-2">No domain performance data available</p>' +
                                    '</div>'
                                );
                            }

                            // Update comments
                            if (facultyData.Comments && facultyData.Comments.length > 0) {
                                displayFacultyDetailsComments(facultyData.Comments);
                            } else {
                                $('#facultyDetailsComments').html('<p class="text-muted text-center">No comments available</p>');
                            }

                            // Load question breakdown
                            loadQuestionBreakdownForSubject(cycleId, facultyId, subjectId, departmentId, courseId);

                        } catch (e) {
                            console.error("Error processing faculty data:", e);
                            hideLoadingOverlay('#facultyDetailsDomainChart');
                            showEmptyChartState();
                            showMessage("Error processing data: " + e.message, "danger");
                        }
                    } else {
                        console.warn("Empty response from server");
                        hideLoadingOverlay('#facultyDetailsDomainChart');
                        showEmptyChartState();
                        showMessage("No data available for this selection", "info");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    hideLoadingOverlay('#facultyDetailsDomainChart');
                    showMessage("Failed to load data: " + error, "danger");
                    showEmptyChartState();
                }
            });
        }
    // Load question breakdown with context
    loadQuestionBreakdownForSubject(cycleId, facultyId, subjectId, departmentId, courseId);


        // Update faculty domain chart - FIXED VERSION
        function updateFacultyDetailsDomainChart(domainScores) {
            console.log("=== updateFacultyDetailsDomainChart (1-5 Scale) ===");
            console.log("Domain scores:", domainScores);

            initializeChartContainer();

            const container = $('#facultyDetailsDomainChart').closest('.chart-container');
            const canvas = document.getElementById('facultyDetailsDomainChart');

            if (facultyDetailsDomainChart) {
                try {
                    facultyDetailsDomainChart.destroy();
                } catch (e) {
                    console.warn("Error destroying existing chart:", e);
                }
                facultyDetailsDomainChart = null;
            }

            if (!domainScores || domainScores.length === 0) {
                container.html(`
            <div class="text-center py-4">
                <i class="bi bi-bar-chart text-muted" style="font-size: 2rem;"></i>
                <p class="mt-2 text-muted">No domain performance data available</p>
            </div>
        `);
                return;
            }

            const validDomains = domainScores.filter(domain => domain && domain.RawScore != null && domain.RawScore > 0);

            if (validDomains.length === 0) {
                container.html(`
            <div class="text-center py-4">
                <i class="bi bi-bar-chart text-muted" style="font-size: 2rem;"></i>
                <p class="mt-2 text-muted">No domain scores available</p>
            </div>
        `);
                return;
            }

            try {
                const ctx = canvas.getContext('2d');

                validDomains.sort((a, b) => b.RawScore - a.RawScore);

                console.log("Creating chart with domains:", validDomains);

                facultyDetailsDomainChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: validDomains.map(d => d.DomainName),
                        datasets: [{
                            label: 'Domain Score (1-5)',
                            data: validDomains.map(d => d.RawScore),
                            backgroundColor: validDomains.map(d => {
                                const score = d.RawScore;
                                if (score >= 4.5) return 'rgba(40, 167, 69, 0.8)';
                                if (score >= 4.0) return 'rgba(23, 162, 184, 0.8)';
                                if (score >= 3.5) return 'rgba(255, 193, 7, 0.8)';
                                if (score >= 3.0) return 'rgba(253, 126, 20, 0.8)';
                                return 'rgba(220, 53, 69, 0.8)';
                            }),
                            borderColor: validDomains.map(d => {
                                const score = d.RawScore;
                                if (score >= 4.5) return 'rgba(40, 167, 69, 1)';
                                if (score >= 4.0) return 'rgba(23, 162, 184, 1)';
                                if (score >= 3.5) return 'rgba(255, 193, 7, 1)';
                                if (score >= 3.0) return 'rgba(253, 126, 20, 1)';
                                return 'rgba(220, 53, 69, 1)';
                            }),
                            borderWidth: 2,
                            borderRadius: 5
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                min: 0,
                                max: 5,
                                ticks: {
                                    stepSize: 1,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                },
                                title: {
                                    display: true,
                                    text: 'Score (1-5 Scale)'
                                }
                            },
                            x: {
                                ticks: {
                                    autoSkip: false,
                                    maxRotation: 45,
                                    minRotation: 45
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        const domain = validDomains[context.dataIndex];
                                        const rawScore = context.raw.toFixed(2);
                                        const weightedScore = domain.Score ? domain.Score.toFixed(1) : '0.0';
                                        const weight = domain.Weight || 0;

                                        return [
                                            `Raw Score: ${rawScore}/5`,
                                            `Weighted Score: ${weightedScore}%`,
                                            `Domain Weight: ${weight}%`,
                                            `Calculation: (${rawScore} ÷ 5) × ${weight} = ${weightedScore}%`
                                        ];
                                    }
                                }
                            }
                        }
                    }
                });

                console.log("Faculty domain chart created successfully with 1-5 scale");

            } catch (error) {
                console.error("Chart creation error:", error);
                container.html(`
            <div class="text-center py-4 text-danger">
                <i class="bi bi-exclamation-triangle" style="font-size: 2rem;"></i>
                <p class="mt-2">Error creating performance chart</p>
                <small>${error.message}</small>
            </div>
        `);
            }
        }

        // Initialize chart container - FIXED VERSION
        function initializeChartContainer() {
            const container = $('#facultyDetailsDomainChart').closest('.chart-container');
            // Always ensure we have a canvas element
            if (container.find('canvas').length === 0) {
                container.html('<canvas id="facultyDetailsDomainChart"></canvas>');
            } else {
                // If canvas exists, make sure it's visible and has the correct ID
                const canvas = container.find('canvas');
                canvas.attr('id', 'facultyDetailsDomainChart').show();
            }
        }
        // Load question breakdown for subject with proper context
        function loadQuestionBreakdownForSubject(cycleId, facultyId, subjectId, departmentId, courseId) {
            console.log("Loading question breakdown:", {
                facultyId: facultyId,
                subjectId: subjectId,
                departmentId: departmentId,
                courseId: courseId,
                cycleId: cycleId
            });

            // Convert "Overall" (-1) to empty string for server-side processing
            if (cycleId === '-1') {
                cycleId = '';
            }

            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetFacultyQuestionBreakdown",
                data: JSON.stringify({
                    cycleId: cycleId,
                    facultyId: facultyId,
                    subjectId: subjectId,
                    departmentId: departmentId,
                    courseId: courseId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Question breakdown response:", response);

                    if (response && response.d) {
                        try {
                            const questionBreakdown = JSON.parse(response.d);
                            buildQuestionBreakdownAccordion(questionBreakdown);
                        } catch (e) {
                            console.error("Error parsing question breakdown data:", e);
                            $('#questionBreakdownAccordion').html(
                                '<div class="text-center py-4 text-muted">Error loading question data: ' + e.message + '</div>'
                            );
                        }
                    } else {
                        $('#questionBreakdownAccordion').html(
                            '<div class="text-center py-4 text-muted">No question data available for this selection</div>'
                        );
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    $('#questionBreakdownAccordion').html(
                        '<div class="text-center py-4 text-muted">Failed to load question data: ' + error + '</div>'
                    );
                }
            });
        }

// Build question breakdown accordion
        function buildQuestionBreakdownAccordion(questionBreakdown) {
            const container = $('#questionBreakdownAccordion');
            container.empty();

            if (!questionBreakdown || questionBreakdown.length === 0) {
                container.html('<div class="text-center py-4 text-muted">No question breakdown data available</div>');
                return;
            }

            let html = '';

            questionBreakdown.forEach((domain, domainIndex) => {
                const domainAverage = domain.DomainAverage || 0;
                const statusClass = getScoreStatusClassForRawScore(domainAverage);

                // Domain section
                html += `
            <div class="mb-4">
                <h6 class="border-bottom pb-2 mb-3">
                    ${domain.DomainName}
                    <span class="badge bg-${statusClass} float-end">${domainAverage.toFixed(2)}/5</span>
                </h6>
                
                <div class="table-responsive">
                    <table class="table table-sm table-hover">
                        <thead class="table-light">
                            <tr>
                                <th width="60%">Question</th>
                                <th width="20%">Score</th>
                                <th width="20%">Responses</th>
                            </tr>
                        </thead>
                        <tbody>
        `;

                // Questions
                domain.Questions.forEach(question => {
                    const avgScore = question.AverageScore || 0;
                    const questionStatusClass = getScoreStatusClassForRawScore(avgScore);

                    html += `
                            <tr>
                                <td class="small">${escapeHtml(question.QuestionText)}</td>
                                <td>
                                    <span class="badge bg-${questionStatusClass}">
                                        ${avgScore.toFixed(2)}/5
                                    </span>
                                </td>
                                <td class="text-muted small">${question.ResponseCount || 0}</td>
                            </tr>
            `;
                });

                html += `
                        </tbody>
                    </table>
                </div>
            </div>
        `;
            });

            container.html(html);
        }

        // Helper function to get status class for 1-5 scale scores
        function getScoreStatusClassForRawScore(score) {
            if (score >= 4.5) return 'success';
            if (score >= 4.0) return 'info';
            if (score >= 3.5) return 'warning';
            if (score >= 3.0) return 'warning';
            return 'danger';
        }
// Display faculty details comments
        function displayFacultyDetailsComments(commentGroups) {
            const container = $('#facultyDetailsComments');

            if (!commentGroups || commentGroups.length === 0) {
                container.html('<p class="text-muted text-center">No comments available for this faculty.</p>');
                return;
            }

            let html = '';

            commentGroups.forEach(group => {
                const groupTitle = group.CommentType;
                const groupCount = group.TotalCount || group.Comments.length;
                const groupIcon = getCommentGroupIcon(groupTitle);
                const groupColor = getCommentGroupColor(groupTitle);

                html += `
            <div class="comment-group mb-4">
                <div class="card border-${groupColor}">
                    <div class="card-header bg-${groupColor} text-white d-flex justify-content-between align-items-center">
                        <h6 class="mb-0">
                            <i class="bi ${groupIcon} me-2"></i>${groupTitle}
                        </h6>
                        <span class="badge bg-light text-dark">${groupCount}</span>
                    </div>
                    <div class="card-body p-0">
                        <div class="list-group list-group-flush">
        `;

                if (group.Comments && group.Comments.length > 0) {
                    group.Comments.forEach((comment, index) => {
                        html += `
                            <div class="list-group-item comment-item">
                                <div class="comment-text">
                                    <p class="mb-0">${escapeHtml(comment.CommentText)}</p>
                                </div>
                            </div>
                `;
                    });
                } else {
                    html += `<div class="list-group-item"><p class="text-muted text-center mb-0">No ${groupTitle.toLowerCase()} comments</p></div>`;
                }

                html += `
                        </div>
                    </div>
                </div>
            </div>
        `;
            });

            container.html(html);
        }


        // Helper functions for comment groups
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

        function getCommentGroupBorderClass(commentType) {
            switch (commentType) {
                case 'Strengths': return 'border-success';
                case 'Weaknesses': return 'border-warning';
                case 'Additional': return 'border-info';
                default: return '';
            }
        }
// Utility Functions
function animateRefreshButton(button) {
    $(button).find('i').addClass('spin');
    setTimeout(() => {
        $(button).find('i').removeClass('spin');
    }, 1000);
}

function hexToRgb(hex) {
    hex = hex.replace('#', '');
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);
    return `${r}, ${g}, ${b}`;
}

function getScoreColor(score) {
    if (score >= 90) return '#1cc88a';
    if (score >= 80) return '#36b9cc';
    if (score >= 70) return '#f6c23e';
    if (score >= 60) return '#fd7e14';
    return '#e74a3b';
}

function getScoreStatusClass(score) {
    if (score >= 90) return 'success';
    if (score >= 80) return 'info';
    if (score >= 70) return 'warning';
    return 'danger';
}

function getScoreStatusText(score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Average';
    return 'Needs Improvement';
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function showMessage(message, type = 'info') {
    $('.alert-dismissible').remove();

    const alert = $(`
        <div class="alert alert-${type} alert-dismissible fade show">
            <i class="bi bi-${type === 'danger' ? 'exclamation-triangle' : type === 'warning' ? 'exclamation-triangle' : 'info-circle'} me-2"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `);
    $('#mainContent').prepend(alert);

    setTimeout(() => {
        alert.alert('close');
    }, 5000);
}

        function showLoadingState(selector, message = 'Loading...') {
            // For KPI section, don't destroy the structure, just show overlay
            if (selector === '#institutionKpiSection') {
                // Add loading overlay without destroying content
                if (!$(selector).find('.loading-overlay').length) {
                    $(selector).append(`
                <div class="loading-overlay" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.8); display: flex; align-items: center; justify-content: center; z-index: 10;">
                    <div class="text-center">
                        <div class="spinner-border text-primary"></div>
                        <p class="mt-2 text-muted">${message}</p>
                    </div>
                </div>
            `);
                }
            } else {
                // Original behavior for other sections
                $(selector).html(`
            <div class="text-center py-4">
                <div class="spinner-border text-primary"></div>
                <p class="mt-2 text-muted">${message}</p>
            </div>
        `);
            }
        }

function showEmptyChartState() {
    $('#facultyDetailsDomainChart').closest('.chart-container').html(
        '<div class="text-center py-4 text-muted">' +
        '<i class="bi bi-bar-chart" style="font-size: 2rem;"></i>' +
        '<p class="mt-2">No chart data available</p>' +
        '</div>'
    );
    $('#questionBreakdownAccordion').html('<div class="text-center py-4 text-muted">No question data available</div>');
    $('#facultyDetailsComments').html('<div class="text-center py-4 text-muted">No comments available</div>');
}
        function setDefaultCycle() {
            console.log("Setting default cycle...");

            // Get default cycle from server
            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetDefaultCycle",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response && response.d) {
                        try {
                            const defaultCycle = JSON.parse(response.d);
                            console.log("Default cycle received:", defaultCycle);

                            if (defaultCycle.CycleID > 0) {
                                // Set all cycle filters to the default cycle
                                $('#<%= hfInstitutionCycleID.ClientID %>').val(defaultCycle.CycleID);
                        $('#<%= hfDepartmentCycleID.ClientID %>').val(defaultCycle.CycleID);
                        $('#<%= hfFacultyCycleID.ClientID %>').val(defaultCycle.CycleID);
                        
                        $('#<%= txtInstitutionCycle.ClientID %>').val(defaultCycle.CycleName);
                        $('#<%= txtDepartmentCycle.ClientID %>').val(defaultCycle.CycleName);
                        $('#<%= txtFacultyCycle.ClientID %>').val(defaultCycle.CycleName);

                        console.log("Default cycle set successfully");

                        // Load data for active tab
                        if ($('#institution').hasClass('active')) {
                            loadInstitutionData();
                        }
                    }
                } catch (e) {
                    console.error("Error parsing default cycle:", e);
                }
            }
        },
        error: function (xhr, status, error) {
            console.error("Error getting default cycle:", error);
        }
    });
        }

        function clearInstitutionCycleSearch() {
            setDefaultCycleForFilter('institution');
            loadInstitutionData();
        }

        function clearDepartmentCycleSearch() {
            setDefaultCycleForFilter('department');
            loadDepartmentData();
        }

        function clearFacultyCycleSearch() {
            setDefaultCycleForFilter('faculty');
            loadFacultyData();
        }
        function setDefaultCycleForFilter(type) {
            // Get current default cycle values
            const defaultCycleId = $('#<%= hfInstitutionCycleID.ClientID %>').val();
    const defaultCycleName = $('#<%= txtInstitutionCycle.ClientID %>').val();

    switch (type) {
        case 'institution':
            $('#<%= hfInstitutionCycleID.ClientID %>').val(defaultCycleId);
            $('#<%= txtInstitutionCycle.ClientID %>').val(defaultCycleName);
            $('#institutionCycleSuggestions').hide();
            break;
        case 'department':
            $('#<%= hfDepartmentCycleID.ClientID %>').val(defaultCycleId);
            $('#<%= txtDepartmentCycle.ClientID %>').val(defaultCycleName);
            $('#departmentCycleSuggestions').hide();
            break;
        case 'faculty':
            $('#<%= hfFacultyCycleID.ClientID %>').val(defaultCycleId);
            $('#<%= txtFacultyCycle.ClientID %>').val(defaultCycleName);
            $('#facultyCycleSuggestions').hide();
            break;
    }
}
function clearFacultyMemberSearch() {
    $('#<%= txtFacultyMember.ClientID %>').val('');
    $('#<%= hfFacultyMemberID.ClientID %>').val('0');
            $('#facultyMemberSuggestions').hide();
            loadFacultyData();
        }


        // Force refresh trend chart
        function forceRefreshTrendChart() {
            console.log("Force refreshing trend chart");

            // Complete cleanup
            if (trendChart) {
                trendChart.destroy();
                trendChart = null;
            }

            // Recreate canvas
            const container = $('#trendChart').closest('.card-body');
            container.empty();
            container.html('<canvas id="trendChart"></canvas>');

            // Reload data
            loadInstitutionData();
        }

        // Update your manual refresh button click handler
        $('#manualRefreshInstitution').click(function (e) {
            e.preventDefault();
            forceRefreshTrendChart();
            animateRefreshButton(this);
        });
        // Clean up all charts before page refresh/navigation
        function cleanupAllCharts() {
            const charts = [trendChart, domainPieChart, departmentRadarChart, facultyDetailsDomainChart];

            charts.forEach((chart, index) => {
                if (chart) {
                    console.log(`Destroying chart ${index}`);
                    try {
                        chart.destroy();
                    } catch (e) {
                        console.warn(`Error destroying chart ${index}:`, e);
                    }
                }
            });

            // Reset all chart variables
            trendChart = null;
            domainBarChart = null;
            departmentRadarChart = null;
            facultyDetailsDomainChart = null;
        }

        // Call cleanup before page unload
        $(window).on('beforeunload', function () {
            cleanupAllCharts();
        });

        // Also clean up when switching tabs
        $('.nav-tabs .nav-link').on('click', function () {
            // Small delay to ensure smooth transition
            setTimeout(cleanupAllCharts, 100);
        });



        // Global chart variable
        var domainPerformanceChart = null;

        // Show department course contribution modal
        function showDepartmentCourseContribution(departmentId, departmentName) {
            console.log("Opening department course modal:", { departmentId, departmentName });

            // Get current cycle from department filters
            const cycleId = $('#<%= hfDepartmentCycleID.ClientID %>').val() || '0';
           console.log("Using cycle ID:", cycleId);

           // Update modal title
           $('#deptCourseModalName').text(departmentName);

           // Reset content
           $('#deptCourseOverallScore').text('Loading...');
           $('#deptCourseCount').text('Loading...');
           $('#domainChartTitle').text('All Courses');
           $('#courseContributionBody').html('<tr><td colspan="7" class="text-center py-4"><div class="spinner-border"></div><p class="mt-2">Loading course data...</p></td></tr>');

           // Clear existing chart
           if (domainPerformanceChart) {
               domainPerformanceChart.destroy();
               domainPerformanceChart = null;
           }

           // Show loading state for chart
           $('#domainPerformanceChart').closest('.chart-container').html(`
        <div class="text-center py-4">
            <div class="spinner-border text-primary"></div>
            <p class="mt-2">Loading domain performance...</p>
        </div>
    `);

           // Show modal first
           $('#departmentCourseModal').modal('show');

           // Load course data with current cycle
           loadDepartmentCourseData(departmentId, cycleId, departmentName);
       }

        // Load department course data
        function loadDepartmentCourseData(departmentId, cycleId, departmentName) {
            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetCourseData",
                data: JSON.stringify({ cycleId: cycleId, departmentId: departmentId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response && response.d) {
                        try {
                            const courses = JSON.parse(response.d);
                            updateCourseModalData(courses, departmentId, cycleId, departmentName);
                        } catch (e) {
                            console.error("Error parsing course data:", e);
                            showErrorState("Error loading course data");
                        }
                    } else {
                        showErrorState("No course data available");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    showErrorState("Failed to load course data");
                }
            });
        }

        // Update course modal with data
        function updateCourseModalData(courses, departmentId, cycleId, departmentName) {
            if (!courses || courses.length === 0) {
                showErrorState("No courses found for this department");
                return;
            }

            // Get the actual department overall score from the department table
            const departmentRow = $(`#departmentTable tr:contains('${departmentName}')`);
            let departmentOverallScore = 0;

            if (departmentRow.length > 0) {
                const scoreText = departmentRow.find('.faculty-score').text();
                departmentOverallScore = parseFloat(scoreText) || 0;
            } else {
                // Fallback: calculate from courses if department row not found
                departmentOverallScore = courses.reduce((sum, course) => sum + course.AverageScore, 0) / courses.length;
            }

            // Update department overview with correct score
            $('#deptCourseOverallScore').text(departmentOverallScore.toFixed(1) + '%');
            $('#deptCourseCount').text(courses.length);

            // Update course table
            updateCourseContributionTable(courses, departmentId, cycleId);

            // Load domain data for all courses
            loadCourseDomainData(0, 'All Courses', departmentId, cycleId);
        }

        // Update course contribution table
        function updateCourseContributionTable(courses, departmentId, cycleId) {
            const tbody = $('#courseContributionBody');

            let html = '';
            courses.forEach(course => {
                const rawScore = course.RawAverage || 0;
                const weightedScore = course.AverageScore || 0;
                const statusClass = getScoreStatusClass(weightedScore);
                const statusText = getScoreStatusText(weightedScore);

                html += `
        <tr class="cursor-pointer" onclick="loadCourseDomainData(${course.CourseID}, '${escapeHtml(course.CourseName)}', ${departmentId}, '${cycleId}')">
            <td class="fw-bold">${escapeHtml(course.CourseName)}</td>
            <td>
                <span class="bold">${weightedScore.toFixed(2)}%</span>
            </td>
            <td>${course.FacultyCount}</td>
            <td>${course.EvaluationCount}</td>
            <td>${course.SubjectCount}</td>
            <td>
                <div class="progress" style="height: 20px;">
                    <div class="progress-bar bg-info" style="width: ${course.ContributionPercent}%">
                        ${course.ContributionPercent}%
                    </div>
                </div>
            </td>
           
        </tr>
    `;
            });

            tbody.html(html);
        }

        // FIXED: Load domain data for specific course
        function loadCourseDomainData(courseId, courseName, departmentId, cycleId) {
            console.log("Loading domain data for course:", courseId, courseName, "with cycle:", cycleId);

            // Update chart title
            $('#domainChartTitle').text(courseName);

            // Show loading state
            const container = $('#departmentCourseModal .chart-container');
            container.html(`
        <div class="text-center py-4">
            <div class="spinner-border text-primary"></div>
            <p class="mt-2">Loading domain performance...</p>
        </div>
    `);

            // Clear existing chart
            if (window.domainPerformanceChart) {
                window.domainPerformanceChart.destroy();
                window.domainPerformanceChart = null;
            }

            // Load data with cycle filter
            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetCourseDomainScores",
                data: JSON.stringify({
                    cycleId: cycleId,
                    departmentId: departmentId,
                    courseId: courseId.toString()
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response && response.d) {
                        try {
                            const domainScores = JSON.parse(response.d);
                            // Render chart immediately
                            renderDomainChart(domainScores, courseName);
                        } catch (e) {
                            console.error("Error parsing domain data:", e);
                            container.html('<div class="text-center py-4 text-muted">Error loading chart data</div>');
                        }
                    } else {
                        container.html('<div class="text-center py-4 text-muted">No domain data available for selected cycle</div>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                    container.html('<div class="text-center py-4 text-muted">Failed to load domain data</div>');
                }
            });
        }
        // FIXED: Render domain chart function
        function renderDomainChart(domainScores, courseName) {
            console.log("=== RENDER DOMAIN CHART (1-5 Scale) ===");
            console.log("Domain scores:", domainScores);

            const container = $('#departmentCourseModal .chart-container');
            console.log("Container found:", container.length);

            if (container.length === 0) {
                console.error("Chart container not found in modal!");
                return;
            }

            if (!domainScores || domainScores.length === 0) {
                container.html('<div class="text-center py-4 text-muted">No domain data available</div>');
                return;
            }

            container.html('<canvas id="domainPerformanceChart"></canvas>');

            const canvas = document.getElementById('domainPerformanceChart');
            const ctx = canvas.getContext('2d');

            const labels = domainScores.map(d => d.DomainName);
            const rawScores = domainScores.map(d => d.RawScore || 0);
            const weightedScores = domainScores.map(d => d.Score || 0);

            if (window.domainPerformanceChart) {
                window.domainPerformanceChart.destroy();
            }

            window.domainPerformanceChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Domain Score (1-5)',
                        data: rawScores,
                        backgroundColor: rawScores.map(score => {
                            if (score >= 4.5) return 'rgba(40, 167, 69, 0.8)';
                            if (score >= 4.0) return 'rgba(23, 162, 184, 0.8)';
                            if (score >= 3.5) return 'rgba(255, 193, 7, 0.8)';
                            if (score >= 3.0) return 'rgba(253, 126, 20, 0.8)';
                            return 'rgba(220, 53, 69, 0.8)';
                        }),
                        borderColor: rawScores.map(score => {
                            if (score >= 4.5) return 'rgba(40, 167, 69, 1)';
                            if (score >= 4.0) return 'rgba(23, 162, 184, 1)';
                            if (score >= 3.5) return 'rgba(255, 193, 7, 1)';
                            if (score >= 3.0) return 'rgba(253, 126, 20, 1)';
                            return 'rgba(220, 53, 69, 1)';
                        }),
                        borderWidth: 2,
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            min: 0,
                            max: 5,
                            ticks: {
                                stepSize: 1,
                                callback: function (value) {
                                    return value.toFixed(1);
                                }
                            },
                            title: {
                                display: true,
                                text: 'Domain Score (1-5 Scale)'
                            }
                        },
                        x: {
                            ticks: {
                                autoSkip: false,
                                maxRotation: 45,
                                minRotation: 45
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    const domain = domainScores[context.dataIndex];
                                    const rawScore = context.raw.toFixed(2);
                                    const weightedScore = domain.Score ? domain.Score.toFixed(1) : '0.0';
                                    const weight = domain.Weight || 0;

                                    return [
                                        `Raw Score: ${rawScore}/5`,
                                        `Weighted Score: ${weightedScore}%`,
                                        `Domain Weight: ${weight}%`,
                                        `Calculation: (${rawScore} ÷ 5) × ${weight} = ${weightedScore}%`
                                    ];
                                }
                            }
                        }
                    }
                }
            });

            console.log("Chart created successfully with 1-5 scale");

            setTimeout(() => {
                if (window.domainPerformanceChart) {
                    window.domainPerformanceChart.update();
                }
            }, 100);
        }

        // Utility function to show error state
        function showErrorState(message) {
            $('#deptCourseOverallScore').text('0%');
            $('#deptCourseCount').text('0');
            $('#courseContributionBody').html(`<tr><td colspan="7" class="text-center py-4 text-muted">${message}</td></tr>`);
            $('#domainPerformanceChart').closest('.chart-container').html('<div class="text-center py-4 text-muted">No data available</div>');
        }

        // Initialize modal event handlers
        $(document).ready(function () {
            // Clean up chart when modal closes
            $('#departmentCourseModal').on('hidden.bs.modal', function () {
                if (domainPerformanceChart) {
                    domainPerformanceChart.destroy();
                    domainPerformanceChart = null;
                }
            });
        });
        // Add chart container styles
        function addChartStyles() {
            if (!$('#department-course-chart-styles').length) {
                $('head').append(`
            <style id="department-course-chart-styles">
                #departmentCourseModal .chart-container {
                    height: 400px;
                    position: relative;
                }
                #departmentCourseModal #domainPerformanceChart {
                    width: 100% !important;
                    height: 100% !important;
                }
            </style>
        `);
            }
        }

        // Initialize styles when page loads
        $(document).ready(function () {
            addChartStyles();
        });
        // Simple test function
        function testDepartmentModal() {
            showDepartmentCourseContribution(6, 'Cite');
        }// Add this function to check the modal structure
        function checkModalStructure() {
            console.log("=== CHECKING MODAL STRUCTURE ===");

            // Check if modal exists
            const modal = $('#departmentCourseModal');
            console.log("Modal exists:", modal.length > 0);
            console.log("Modal is visible:", modal.hasClass('show'));

            // Check for chart container
            const chartContainer = $('#departmentCourseModal .chart-container');
            console.log("Chart container found:", chartContainer.length);
            console.log("Chart container HTML:", chartContainer.html());

            // Check for canvas
            const canvas = $('#departmentCourseModal #domainPerformanceChart');
            console.log("Canvas found:", canvas.length);

            return chartContainer.length > 0;
        }

        // Run this in console when modal is open: checkModalStructure()
        // Add this function to fix chart dimensions
        function fixChartDimensions() {
            const style = `
        <style id="chart-dimension-fix">
            #departmentCourseModal .chart-container {
                height: 400px !important;
                min-height: 400px !important;
                position: relative !important;
            }
            #departmentCourseModal #domainPerformanceChart {
                width: 100% !important;
                height: 100% !important;
                display: block !important;
            }
        </style>
    `;

            if (!$('#chart-dimension-fix').length) {
                $('head').append(style);
            }
        }

        // Call this when page loads
        $(document).ready(function () {
            fixChartDimensions();
        });



    </script>
    <script type="text/javascript">
        // Simple, direct approach that works like the test button
        function initializeSidebar() {
            console.log('=== INITIALIZING SIDEBAR ===');

            // Get elements
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            const desktopToggler = document.getElementById('sidebarToggler');
            const mobileToggler = document.getElementById('mobileSidebarToggler');

            console.log('Elements found:', {
                sidebar: !!sidebar,
                mainContent: !!mainContent,
                desktopToggler: !!desktopToggler,
                mobileToggler: !!mobileToggler
            });

            if (!sidebar) {
                console.error('Sidebar element not found!');
                return;
            }

            // Load saved state
            const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
            console.log('Saved state:', isCollapsed);

            if (isCollapsed) {
                sidebar.classList.add('collapsed');
                if (mainContent) mainContent.classList.add('collapsed');
                if (desktopToggler) desktopToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
            }

            // Desktop toggle - USE DIRECT ONCLICK (like test button)
            if (desktopToggler) {
                console.log('Setting up desktop toggler');
                desktopToggler.onclick = function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    console.log('Desktop toggle clicked');

                    sidebar.classList.toggle('collapsed');
                    if (mainContent) mainContent.classList.toggle('collapsed');

                    // Update icon
                    if (sidebar.classList.contains('collapsed')) {
                        this.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
                        localStorage.setItem('sidebarCollapsed', 'true');
                    } else {
                        this.innerHTML = '<i class="bi bi-arrow-left-circle"></i>';
                        localStorage.setItem('sidebarCollapsed', 'false');
                    }
                };
            }

            // Mobile toggle - USE DIRECT ONCLICK
            if (mobileToggler) {
                console.log('Setting up mobile toggler');
                mobileToggler.onclick = function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    console.log('Mobile toggle clicked');
                    sidebar.classList.toggle('mobile-show');
                };
            }

            console.log('=== SIDEBAR INITIALIZATION COMPLETE ===');
        }

        // Multiple initialization methods to ensure it runs
        document.addEventListener('DOMContentLoaded', function () {
            console.log('DOMContentLoaded - initializing sidebar');
            initializeSidebar();
        });

        window.addEventListener('load', function () {
            console.log('Window load - initializing sidebar');
            initializeSidebar();
        });

        // jQuery backup
        $(document).ready(function () {
            console.log('jQuery ready - initializing sidebar');
            initializeSidebar();
        });

        // Final backup - initialize after a delay
        setTimeout(function () {
            console.log('Timeout - initializing sidebar');
            initializeSidebar();
        }, 1000);
    </script>
    <script type="text/javascript">
        // Global functions as backup (called by onclick attributes)
        function toggleDesktopSidebar() {
            console.log('Global desktop toggle function called');
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');
            const desktopToggler = document.getElementById('sidebarToggler');

            if (sidebar) {
                sidebar.classList.toggle('collapsed');
                if (mainContent) mainContent.classList.toggle('collapsed');

                // Update icon
                if (sidebar.classList.contains('collapsed')) {
                    if (desktopToggler) desktopToggler.innerHTML = '<i class="bi bi-arrow-right-circle"></i>';
                    localStorage.setItem('sidebarCollapsed', 'true');
                } else {
                    if (desktopToggler) desktopToggler.innerHTML = '<i class="bi bi-arrow-left-circle"></i>';
                    localStorage.setItem('sidebarCollapsed', 'false');
                }
            }
        }

        function toggleMobileSidebar() {
            console.log('Global mobile toggle function called');
            const sidebar = document.getElementById('sidebar');
            if (sidebar) {
                sidebar.classList.toggle('mobile-show');
            }
        }

        // Function to update sidebar badges
        function updateSidebarBadges() {
            $.ajax({
                type: "POST",
                url: "Reports.aspx/GetSidebarBadgeCounts",
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


