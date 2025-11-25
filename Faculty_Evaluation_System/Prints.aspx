
<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Prints.aspx.vb" Inherits="Faculty_Evaluation_System.Prints" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Evaluation Reports - Faculty Evaluation System</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/smoothness/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
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

    .content {
        margin-left: var(--sidebar-width);
        margin-top: var(--header-height);
        padding: 2rem;
        min-height: calc(100vh - var(--header-height));
        transition: all 0.3s ease;
    }

    .content.collapsed {
        margin-left: var(--sidebar-collapsed-width);
    }

    .header-logo {
        height: 40px;
        width: auto;
        object-fit: contain;
        max-width: 150px;
    }

    .stat-card {
        background: white;
        border-radius: 0.5rem;
        padding: 1.5rem;
        border-left: 4px solid var(--primary);
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
    }

    .stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    }

    .department-card {
        background: white;
        border-radius: 0.5rem;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        border: 1px solid #e9ecef;
    }

    .card {
        border: none;
        border-radius: 0.5rem;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 1.5rem;
    }

    .card-header {
        background-color: #f8f9fc;
        border-bottom: 1px solid #e3e6f0;
        padding: 1rem 1.25rem;
        font-weight: 700;
    }

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

    .print-header {
        display: none;
    }

    @media print {
        .no-print {
            display: none !important;
        }
        
        /* Hide KPI cards in print */
        .kpi-card {
            display: none !important;
        }

        .header-bar,
        .sidebar,
        .btn,
        .print-actions,
        .search-panel,
        .subject-selector {
            display: none !important;
        }

        .content {
            margin: 0 !important;
            padding: 0 !important;
            width: 100% !important;
        }

        .card {
            border: 1px solid #000 !important;
            box-shadow: none !important;
            margin-bottom: 1rem;
            page-break-inside: avoid;
        }

        .card-header {
            background: #f8f9fa !important;
            color: #000 !important;
            border-bottom: 2px solid #000 !important;
        }

        .table {
            border: 1px solid #000;
            font-size: 11px;
        }

        .table th,
        .table td {
            border: 1px solid #000 !important;
            padding: 6px;
        }

        .table th {
            background: #f8f9fa !important;
            color: #000 !important;
        }

        .print-header {
            display: block !important;
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #000;
        }

        .print-section {
            page-break-inside: avoid;
        }

        .kpi-card {
            border: 1px solid #000 !important;
            margin-bottom: 1rem;
        }

        .comment-card {
            border: 1px solid #000 !important;
            margin-bottom: 0.5rem;
            page-break-inside: avoid;
        }
    }

    .table th {
        border-top: none;
        font-weight: 700;
        color: var(--dark);
        background-color: #f8f9fc;
    }

    .table-hover tbody tr:hover {
        background-color: rgba(26, 58, 143, 0.05);
    }

    .performance-badge {
        font-size: 0.75rem;
        padding: 0.25rem 0.5rem;
    }

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

    .comment-card {
        background: #f8f9fa;
        border-left: 4px solid var(--primary);
        margin-bottom: 1rem;
        transition: all 0.3s ease;
    }

    .comment-card:hover {
        background: #e9ecef;
        transform: translateX(5px);
    }

    .comment-meta {
        font-size: 0.875rem;
        color: #6c757d;
    }

    .comment-text {
        color: #495057;
        line-height: 1.5;
    }

    .subject-selector {
        background: linear-gradient(135deg, #f8f9fc 0%, #e9ecef 100%);
        border-radius: 0.5rem;
        border-left: 4px solid var(--gold);
    }

    .subject-card {
        transition: all 0.3s ease;
        border: 1px solid #e3e6f0;
        cursor: pointer;
        height: 100%;
        border-left: 4px solid var(--primary);
    }

    .subject-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        border-color: var(--primary);
    }

    .subject-card.selected {
        border-color: var(--primary);
        background: linear-gradient(135deg, #f8f9fc 0%, #e9ecef 100%);
        transform: scale(1.02);
    }

    .all-subjects-card {
        border-left: 4px solid var(--gold);
    }

    .subject-stats {
        border-top: 1px solid #e3e6f0;
        padding-top: 0.75rem;
        margin-top: 0.75rem;
    }

    .subject-icon {
        font-size: 2.5rem;
        margin-bottom: 1rem;
    }

    .weighted-badge {
        background: linear-gradient(135deg, var(--gold) 0%, var(--gold-dark) 100%);
    }

    .latest-cycle-badge {
        background: linear-gradient(135deg, var(--success) 0%, #20c997 100%);
    }

    @media (max-width: 768px) {
        .sidebar {
            left: calc(-1 * var(--sidebar-width));
            width: var(--sidebar-width);
        }

        .sidebar.mobile-show {
            left: 0;
        }

        .content,
        .content.collapsed {
            margin-left: 0;
            padding: 1rem;
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

        .table-responsive {
            border: 1px solid #dee2e6;
            border-radius: 0.375rem;
        }

        .page-header {
            flex-direction: column;
            align-items: flex-start !important;
        }

        .page-header .btn {
            margin-top: 0.5rem;
            align-self: flex-end;
        }

        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }

        .action-buttons .btn {
            margin-bottom: 0.25rem;
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
        }

        .subject-card {
            margin-bottom: 1rem;
        }
    }

    #mobileSidebarToggler {
        background: rgba(255, 255, 255, 0.2);
        border-color: rgba(255, 255, 255, 0.5);
        color: white;
    }

    #mobileSidebarToggler:hover {
        background: rgba(255, 255, 255, 0.3);
    }

    .page-title {
        color: var(--primary);
        border-bottom: 2px solid var(--gold);
        padding-bottom: 0.5rem;
    }

    .gold-accent {
        color: var(--gold);
    }

    .card-header h5 {
        color: var(--primary);
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

    .text-primary {
        color: var(--primary) !important;
    }

    .text-info {
        color: var(--primary-light) !important;
    }

    .form-control:focus, .form-select:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
    }

    .table th i {
        color: var(--primary);
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

    .kpi-card {
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        border: 1px solid #e3e6f0;
    }

    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    }

    .badge.bg-primary {
        background-color: var(--primary) !important;
    }

    .faculty-row:hover {
        background-color: rgba(26, 58, 143, 0.05);
        cursor: pointer;
        transform: translateX(2px);
        transition: all 0.2s ease;
    }

    .domain-header-row {
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%) !important;
        color: white;
    }

    .progress-bar {
        background-color: var(--primary);
    }

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

    .search-panel {
        background-color: #f8f9fc;
        border-radius: 0.35rem;
        border-left: 3px solid var(--gold);
    }

    .stat-card .text-primary { color: var(--primary) !important; }
    .stat-card .text-success { color: var(--success) !important; }
    .stat-card .text-info { color: var(--info) !important; }
    .stat-card .text-warning { color: var(--gold) !important; }

    .badge.bg-success { background-color: var(--success) !important; }
    .badge.bg-warning { background-color: var(--gold) !important; }
    .badge.bg-danger { background-color: var(--danger) !important; }
    .badge.bg-info { background-color: var(--info) !important; }

    .print-actions .btn {
        margin-left: 0.5rem;
    }

    @media (max-width: 576px) {
        .stat-card h3 {
            font-size: 1.5rem;
        }
        
        .stat-card h6 {
            font-size: 0.875rem;
        }
    }
    .comment-section {
    margin-bottom: 0;
    border: 1px solid #dee2e6;
    border-radius: 0.375rem;
    overflow: hidden;
}

.comment-section:not(:last-child) {
    margin-bottom: 1.5rem;
}

.section-header {
    border-bottom: 2px solid rgba(255, 255, 255, 0.2);
}

.section-body {
    background-color: #fff;
}

.comment-item:last-child {
    border-bottom: none !important;
    margin-bottom: 0 !important;
    padding-bottom: 0 !important;
}

.comment-content {
    line-height: 1.6;
    color: #495057;
}

.comment-text {
    font-size: 0.95rem;
    display: inline;
}
@media print {
    /* Make student comments cleaner and more compact */
    .comment-section {
        margin-bottom: 0.5rem !important;
        border: 1px solid #ccc !important;
        page-break-inside: avoid;
    }

    .section-header {
        padding: 0.3rem 0.5rem !important;
        margin-bottom: 0.2rem !important;
        background: #f8f9fa !important;
        color: #000 !important;
        border-bottom: 1px solid #000 !important;
    }

    .section-header h5 {
        font-size: 10pt !important;
        margin: 0 !important;
        font-weight: bold;
    }

    .section-body {
        padding: 0.3rem 0.5rem !important;
        font-size: 9pt !important;
    }

    .comment-item {
        margin-bottom: 0.2rem !important;
        padding-bottom: 0.2rem !important;
        border-bottom: 1px dotted #ddd !important;
        page-break-inside: avoid;
    }

    .comment-item:last-child {
        border-bottom: none !important;
        margin-bottom: 0 !important;
        padding-bottom: 0 !important;
    }

    .comment-text {
        font-size: 9pt !important;
        line-height: 1.3 !important;
        color: #000 !important;
    }

    /* Remove icons and badges in print for comments */
    .comment-content .bi-quote,
    .section-header .badge,
    .section-header i {
        display: none !important;
    }

    /* Make question breakdown font consistent with comments */
    .table {
        font-size: 9pt !important;
    }

    .table th,
    .table td {
        font-size: 9pt !important;
        padding: 3px 4px !important;
    }

    /* Ensure domain headers in question breakdown have consistent font */
    .domain-header-row {
        background: #f8f9fa !important;
        color: #000 !important;
        font-size: 9pt !important;
    }

    .domain-header-row td {
        font-weight: bold;
        font-size: 9pt !important;
    }

    /* Remove icons from question breakdown in print */
    .domain-header-row .bi-collection {
        display: none !important;
    }

    /* Compact layout for comments */
    .compact-comment .comment-item {
        margin-bottom: 0.15rem !important;
        padding-bottom: 0.15rem !important;
    }

    .compact-comment .comment-text {
        font-size: 9pt !important;
        line-height: 1.2 !important;
    }

    /* Remove background colors from comment sections in print */
    .bg-success,
    .bg-warning,
    .bg-info {
        background-color: #f8f9fa !important;
        color: #000 !important;
    }

    /* Ensure all text is black in print for better readability */
    .comment-section * {
        color: #000 !important;
    }

    /* Remove any remaining colors that might affect print */
    .text-success,
    .text-warning,
    .text-info {
        color: #000 !important;
    }
}

/* Additional screen-only styles for better visual separation */
@media screen {
    .comment-section {
        box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        transition: box-shadow 0.15s ease-in-out;
    }
    
    .comment-section:hover {
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    }
    
    .comment-item {
        transition: background-color 0.15s ease-in-out;
    }
    
    .comment-item:hover {
        background-color: #f8f9fa;
    }
}

/* Ensure proper page breaks */
@page {
    margin: 0.5in;
}

.section-header, 
.comment-item,
.domain-header-row {
    page-break-inside: avoid;
}

.comment-section {
    page-break-inside: auto;
}

/* Consistent font sizes for screen view */
@media screen {
    .comment-text {
        font-size: 0.9rem;
        line-height: 1.4;
    }

    .table {
        font-size: 0.9rem;
    }
}
@media print {
    @page {
        margin: 0.25in;
        size: letter;
    }
    
    body {
        font-size: 10pt;
        line-height: 1.2;
    }
    
    .no-print {
        display: none !important;
    }
    
    /* Hide KPI cards in print */
    .kpi-card {
        display: none !important;
    }
    
    .header-bar,
    .sidebar,
    .btn,
    .print-actions,
    .search-panel,
    .subject-selector {
        display: none !important;
    }
    
    .content {
        margin: 0 !important;
        padding: 0 !important;
        width: 100% !important;
    }
    
    /* Ensure all content is visible */
    .subject-card,
    .individual-subject-card,
    .all-subjects-card {
        display: block !important;
        page-break-inside: avoid;
    }
    
    /* Compact layouts */
    .card {
        border: 1px solid #000 !important;
        box-shadow: none !important;
        margin-bottom: 0.3rem;
        page-break-inside: avoid;
    }
    
    .card-header {
        background: #f8f9fa !important;
        color: #000 !important;
        border-bottom: 1px solid #000 !important;
        padding: 0.3rem !important;
    }
    
    .card-body {
        padding: 0.3rem !important;
    }
    
    .table {
        border: 1px solid #000;
        font-size: 8pt;
    }
    
    .table th,
    .table td {
        border: 1px solid #000 !important;
        padding: 2px 3px;
    }
    
    .table th {
        background: #f8f9fa !important;
        color: #000 !important;
    }
    
    /* Comment sections optimization for print - more compact */
    .comment-section {
        margin-bottom: 0.3rem;
        border: 1px solid #ccc !important;
    }
    
    .section-header {
        padding: 0.2rem 0.5rem !important;
        margin-bottom: 0.2rem !important;
    }
    
    .section-header h5 {
        font-size: 9pt !important;
        margin: 0 !important;
    }
    
    .section-body {
        padding: 0.3rem 0.5rem !important;
    }
    
    .comment-item {
        margin-bottom: 0.1rem !important;
        padding-bottom: 0.1rem !important;
        border-bottom: 1px dotted #eee !important;
        page-break-inside: avoid;
    }
    
    .comment-item:last-child {
        border-bottom: none !important;
    }
    
    .comment-text {
        font-size: 8pt !important;
        line-height: 1.2 !important;
    }
    
    /* Remove icons and badges in print for comments */
    .comment-content .bi-quote,
    .section-header .badge {
        display: none !important;
    }
    
    /* Compact comment layout */
    .compact-comment .comment-item {
        margin-bottom: 0.1rem !important;
        padding-bottom: 0.1rem !important;
    }
    
    .compact-comment .comment-text {
        font-size: 8pt !important;
    }
}

@media screen {
    .comment-section {
        box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        transition: box-shadow 0.15s ease-in-out;
    }
    
    .comment-section:hover {
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    }
    
    .comment-item {
        transition: background-color 0.15s ease-in-out;
    }
    
    .comment-item:hover {
        background-color: #f8f9fa;
    }
}

@page {
    margin: 0.5in;
}

.section-header, .comment-item {
    page-break-inside: avoid;
}

.comment-section {
    page-break-inside: auto;
}

.compact-comment .comment-item {
    margin-bottom: 0.25rem !important;
    padding-bottom: 0.25rem !important;
}

.compact-comment .comment-text {
    font-size: 0.9rem !important;
}
/* Enhanced Print Header Styles */
.print-header {
    display: none;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid #000;
}

@media print {
    .print-header {
        display: block !important;
        page-break-inside: avoid;
    }
    
    .print-header-content {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 0.5rem;
    }
    
    .print-logo-section {
        flex: 0 0 20%;
    }
    
    
    
    .print-institution-info {
        flex: 0 0 50%;
        text-align: center;
    }
    
    .print-institution-info h2 {
        font-size: 14pt;
        font-weight: bold;
        margin: 0 0 2px 0;
        text-transform: uppercase;
    }
    
    .institution-address {
        font-size: 9pt;
        margin: 0 0 1px 0;
    }
    
    .institution-contact {
        font-size: 8pt;
        margin: 0;
    }
    
    .print-admin-section {
        flex: 0 0 25%;
        text-align: center;
    }
    
    .admin-name {
        font-size: 10pt;
        margin: 0 0 5px 0;
        min-height: 15px;
    }
    
    .signature-line {
        border-top: 1px solid #000;
        width: 100%;
        margin: 5px 0;
        height: 1px;
    }
    
    .signature-label {
        font-size: 8pt;
        margin: 0;
        font-style: italic;
    }
    
    .report-title-section {
        text-align: center;
        margin-top: 0.5rem;
    }
    
    .report-title-section h3 {
        font-size: 12pt;
        font-weight: bold;
        margin: 0 0 3px 0;
        text-transform: uppercase;
    }
    
    .report-date {
        font-size: 9pt;
        margin: 0;
    }
    
    /* Optimize space usage */
    .card {
        margin-bottom: 0.5rem;
        page-break-inside: avoid;
    }
    
    .card-body {
        padding: 0.5rem;
    }
    
    .card-header {
        padding: 0.5rem;
    }
    
    .table {
        font-size: 9pt;
        margin-bottom: 0.5rem;
    }
    
    .table th, .table td {
        padding: 3px;
    }
    
    /* Ensure all subjects display in print */
    .subject-card, .individual-subject-card {
        display: block !important;
        page-break-inside: avoid;
    }
}
/* Enhanced Print Header Styles */
.print-header {
    display: none;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid #000;
}

@media print {
    .print-header {
        display: block !important;
        page-break-inside: avoid;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .print-header-content {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 0.5rem;
    }
     .header-logo {
        display: none !important;
    }
    .print-logo-section {
        flex: 0 0 20%;
    }
    
   
    
    .print-institution-info {
        flex: 0 0 50%;
        text-align: center;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .print-institution-info h2 {
        font-size: 18pt;
        font-weight: bold;
        margin: 0 0 3px 0;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .institution-address {
        font-size: 11pt;
        margin: 0 0 2px 0;
        font-weight: normal;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .institution-contact {
        font-size: 10pt;
        margin: 0;
        font-weight: normal;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .print-admin-section {
        flex: 0 0 25%;
        text-align: center;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .admin-name {
        font-size: 11pt;
        margin: 0 0 8px 0;
        min-height: 15px;
        font-weight: bold;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .signature-line {
        border-top: 1px solid #000;
        width: 100%;
        margin: 8px 0 3px 0;
        height: 1px;
    }
    
    .signature-label {
        font-size: 9pt;
        margin: 0;
        font-style: italic;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .report-title-section {
        text-align: center;
        margin-top: 0.8rem;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .report-title-section h3 {
        font-size: 14pt;
        font-weight: bold;
        margin: 0 0 5px 0;
        text-transform: uppercase;
        font-family: 'Times New Roman', Times, serif;
    }
    
    .report-date {
        font-size: 11pt;
        margin: 0;
        font-weight: normal;
        font-family: 'Times New Roman', Times, serif;
    }
}
/* Completely remove KPI cards */
.kpi-card,
.no-print-kpi {
    display: none !important;
}

/* Ensure KPI cards are removed in print */
@media print {
    .kpi-card,
    .no-print-kpi {
        display: none !important;
    }
    
    /* Also hide the entire KPI row */
    .row.no-print-kpi {
        display: none !important;
    }
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
                                <!-- NEW RELEASE RESULTS PAGE -->
               <a href="ReleaseResults.aspx" class="list-group-item list-group-item-action position-relative">
    <i class="bi bi-send-check"></i>
    <span class="list-group-text">Release Results</span>
    <asp:Label ID="sidebarReleaseBadge" runat="server" 
              CssClass="badge bg-danger rounded-pill"
              Visible="false"></asp:Label>
</a>
                <a href="Prints.aspx" class="list-group-item list-group-item-action active">
                    <i class="bi bi-printer"></i>
                    <span class="list-group-text">Reports</span>
                </a>
            </div>
            
            <button id="sidebarToggler" class="sidebar-toggler d-none d-lg-block">
                <i class="bi bi-arrow-left-circle"></i>
            </button>
        </div>

        <!-- Main Content -->
        <div class="content">
      <!-- Print Header -->
<!-- Print Header -->
<div class="print-header">
    <div class="print-header-content">
        <div class="print-logo-section">
            <!-- Remove the logo-circle div and use the image directly -->
            <img src="image/logo.png" alt="Golden West Colleges Logo" 
                 style="max-width: 60px; max-height: 60px; display: block; margin: 0 auto;" 
                 onerror="this.style.display='none'" />
        </div>
        <div class="print-institution-info">
            <h2>Golden West Colleges Inc.</h2>
            <p class="institution-address">San Jose Drive, Alaminos City, Pangasinan</p>
            <p class="institution-contact">Tel.no.(075)552 7382 Email Address: goldenwestcolleges@yahoo.com</p>
        </div>
        <div class="print-admin-section">
            <p class="admin-name"><asp:Literal ID="litPreparedBy" runat="server" /></p>
            <div class="signature-line"></div>
            <p class="signature-label">Prepared By</p>
        </div>
    </div>
    <div class="report-title-section">
        <h3>Faculty Evaluation Report</h3>
        <p class="report-date"><strong>Report Date:</strong> <asp:Label ID="lblPrintDate" runat="server" /></p>
    </div>
</div>

            <!-- Evaluation List Panel -->
            <asp:Panel ID="pnlEvaluationList" runat="server" Visible="true">
                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-center mb-4 no-print">
                    <div>
                        <h2 class="mb-1 page-title"><i class="bi bi-printer me-2 gold-accent"></i>Evaluation Reports</h2>
                        <p class="text-muted mb-0">Generate and print faculty evaluation reports</p>
                    </div>
                    <div class="print-actions">
                        <asp:Button ID="btnExportExcel" runat="server" Text="Export Excel" 
                            CssClass="btn btn-success" OnClick="btnExportExcel_Click" />
                    </div>
                </div>

              

              

           
<!-- Search Panel -->
<div class="card mb-4 search-panel no-print">
    <div class="card-body">
        <div class="row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label fw-semibold">Faculty Name</label>
                <asp:TextBox ID="txtSearchFaculty" runat="server" CssClass="form-control" placeholder="Search faculty..."></asp:TextBox>
            </div>
            <div class="col-md-3">
                <label class="form-label fw-semibold">Department</label>
                <asp:DropDownList ID="ddlFilterDepartment" runat="server" CssClass="form-select">
                    <asp:ListItem Value="" Text="All Departments"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-4">
                <label class="form-label fw-semibold">Evaluation Cycle</label>
                <asp:TextBox ID="txtFilterCycle" runat="server" CssClass="form-control" placeholder="Type cycle name or term..."></asp:TextBox>
            </div>
            <div class="col-md-2">
                <div class="d-grid">
                    <asp:Button ID="btnApplyFilters" runat="server" Text="Apply Filters" 
                        CssClass="btn btn-primary" OnClick="btnApplyFilters_Click" />
                </div>
            </div>
        </div>
    </div>
</div>
               <!-- Faculty Evaluation List -->
<div class="card">
    <div class="card-header bg-transparent py-3 d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold text-primary"><i class="bi bi-list-check me-2"></i>Faculty Evaluation Summary</h5>
        <span class="badge bg-primary rounded-pill" id="visibleCountBadge">
            <asp:Literal ID="litVisibleCount" runat="server" Text="0" />
        </span>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Faculty Name</th>
                        <th>Department</th>
                        <th class="text-center">Weighted Score</th>
                        <th class="text-center">Raw Score</th>
                        <th class="text-center">Subjects</th>
                        <th class="text-center">Evaluations</th>
                        <th class="text-center">Response Rate</th>
                        <th class="text-center no-print">Action</th>
                    </tr>
                </thead>
                <tbody>
                   <asp:Repeater ID="rptEvaluationList" runat="server" OnItemCommand="rptEvaluationList_ItemCommand">
    <ItemTemplate>
        <tr class="faculty-row" 
            data-faculty='<%# Eval("FacultyName") %>'
            data-department='<%# Eval("DepartmentName") %>'
            data-department-id='<%# Eval("DepartmentID") %>'
            data-cycle='<%# Eval("CycleName") %>'
            data-term='<%# Eval("Term") %>'
            data-status='<%# Eval("Status") %>'
            data-is-latest='<%# IsLatestCycle(Eval("CycleID")) %>'>
            <td class="fw-semibold"><%# Eval("FacultyName") %></td>
            <td><%# Eval("DepartmentName") %></td>
            <td class="text-center">
                <span class='badge <%# GetScoreClass(Eval("WeightedScore")) %> p-2'>
                    <%# Eval("WeightedScore", "{0:N1}") %>%
                </span>
            </td>
            <td class="text-center fw-semibold">
                <%# Eval("RawScore", "{0:N2}") %>/5.0
            </td>
            <td class="text-center"><%# Eval("SubjectsCount") %></td>
            <td class="text-center"><%# Eval("EvaluationsCount") %></td>
            <td class="text-center"><%# Eval("ResponseRate", "{0:N0}") %>%</td>
            <td class="text-center no-print">
                <asp:LinkButton runat="server" CommandName="SelectEvaluation" 
                    CommandArgument='<%# GetCommandArgument(Eval("FacultyID"), Eval("CycleID"), Eval("CycleName"), Eval("Term")) %>'
                    CssClass="btn btn-outline-primary btn-sm">
                    <i class="bi bi-eye me-1"></i>View Report
                </asp:LinkButton>
            </td>
        </tr>
    </ItemTemplate>
</asp:Repeater>
                </tbody>
            </table>
        </div>

        <asp:Panel ID="pnlNoEvaluations" runat="server" Visible="false" class="text-center py-5">
            <i class="bi bi-clipboard-x display-4 text-muted d-block mb-3"></i>
            <h4 class="text-muted">No Evaluation Records Found</h4>
            <p class="text-muted">There are no faculty evaluation records available for the selected criteria.</p>
        </asp:Panel>
    </div>
</div>
            </asp:Panel>

            <!-- Subject Selection Panel -->
            <asp:Panel ID="pnlSubjectSelection" runat="server" Visible="false">
                <div class="d-flex justify-content-between align-items-center mb-4 no-print">
                    <asp:Button ID="btnBackToSubjectList" runat="server" Text="← Back to List" 
                        CssClass="btn btn-outline-secondary" OnClick="btnBackToSubjectList_Click" />
                </div>

                <div class="card subject-selector">
                    <div class="card-header bg-transparent py-3">
                        <h5 class="mb-0 fw-bold text-primary">
                            <i class="bi bi-journals me-2"></i>Select Subject for Detailed Report
                        </h5>
                    </div>
                    <div class="card-body">
                        <!-- Faculty Information -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <h6 class="text-primary">Faculty Information</h6>
                                <p class="mb-1"><strong>Name:</strong> <asp:Literal ID="litSelectedFaculty" runat="server" /></p>
                                <p class="mb-1"><strong>Department:</strong> <asp:Literal ID="litSelectedDepartment" runat="server" /></p>
                                <p class="mb-0"><strong>Term:</strong> <asp:Literal ID="litSelectedTerm" runat="server" /></p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-primary">Evaluation Cycle</h6>
                                <p class="mb-1"><strong>Current Cycle:</strong> <asp:Literal ID="litCurrentCycle" runat="server" /></p>
                                <p class="mb-0"><strong>Status:</strong> <span class="badge bg-success">Latest Results</span></p>
                            </div>
                        </div>
                        
                     <!-- Subject Cards Grid -->
<div class="row">
  <!-- All Subjects Card -->
<div class="col-md-4 mb-3">
    <div class="card h-100 subject-card all-subjects-card" 
         data-subject-id="all"
         data-subject-name="All Subjects"
         style="cursor: pointer;">
        <div class="card-body text-center">
            <i class="bi bi-collection subject-icon text-warning"></i>
            <h5 class="card-title">All Subjects</h5>
            <p class="card-text text-muted">View aggregated report across all subjects with weighted averages</p>
            <div class="mt-3">
                <span class="badge weighted-badge">Weighted Average Report</span>
            </div>
        </div>
    </div>
</div>

   <!-- Individual Subject Cards -->
<asp:Repeater ID="rptSubjectCards" runat="server">
    <ItemTemplate>
        <div class="col-md-4 mb-3">
            <div class="card h-100 subject-card individual-subject-card" 
                 data-subject-id='<%# Eval("SubjectID") %>'
                 data-subject-name='<%# Eval("SubjectName") %>'
                 style="cursor: pointer;">
                <div class="card-body">
                    <h6 class="card-title text-primary">
                        <i class="bi bi-journal me-1"></i>
                        <%# Eval("SubjectName") %>
                    </h6>
                    <p class="card-text small text-muted mb-2">
                        <i class="bi bi-code-slash me-1"></i>
                        <%# Eval("SubjectCode") %>
                    </p>
                    
                    <div class="subject-stats">
                        <div class="d-flex justify-content-between small mb-1">
                            <span><i class="bi bi-clipboard-check me-1"></i>Evaluations:</span>
                            <span class="fw-bold text-info"><%# Eval("EvaluationCount") %></span>
                        </div>
                        <div class="d-flex justify-content-between small mb-1">
                            <span><i class="bi bi-graph-up me-1"></i>Weighted Score:</span>
                            <span class='badge <%# GetScoreClass(Eval("WeightedScore")) %> performance-badge'>
                                <%# FormatNumber(Eval("WeightedScore"), 1) %>%
                            </span>
                        </div>
                        <div class="d-flex justify-content-between small">
                            <span><i class="bi bi-people me-1"></i>Response Rate:</span>
                            <span class="fw-bold text-success"><%# FormatNumber(Eval("ResponseRate"), 0) %>%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>
    </div>
                        <!-- No Subjects Message -->
                        <asp:Panel ID="pnlNoSubjects" runat="server" Visible="false" class="text-center py-4">
                            <i class="bi bi-journals display-4 text-muted d-block mb-3"></i>
                            <h4 class="text-muted">No Subjects Available</h4>
                            <p class="text-muted">There are no subjects assigned to this faculty for the selected term.</p>
                        </asp:Panel>

                        <!-- Hidden elements for report generation -->
                        <asp:HiddenField ID="hfSelectedSubjectID" runat="server" Value="" />
                        <asp:HiddenField ID="hfSelectedSubjectName" runat="server" Value="" />
                        <asp:Button ID="btnGenerateReportHidden" runat="server" 
                                    OnClick="btnGenerateReportHidden_Click" 
                                    Style="display: none;" />
                    </div>
                </div>
            </asp:Panel>

            <!-- Detailed Report Panel -->
            <asp:Panel ID="pnlDetailedReport" runat="server" Visible="false">
                <!-- Back Button and Print Action -->
                <div class="d-flex justify-content-between align-items-center mb-4 no-print">
                    <asp:Button ID="btnBackToSubject" runat="server" Text="← Back to Subject Selection" 
                        CssClass="btn btn-outline-secondary" OnClick="btnBackToSubject_Click" />
                    <div>
                        <button type="button" class="btn btn-primary" onclick="window.print()">
                            <i class="bi bi-printer me-1"></i>Print Report
                        </button>
                    </div>
                </div>

                <!-- Executive Summary -->
                <div class="card mb-4 print-section">
                    <div class="card-header bg-transparent py-3">
                        <h5 class="mb-0 fw-bold text-primary">Executive Summary</h5>
                    </div>
                    <div class="card-body">
                        <!-- Faculty Information -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <table class="table table-bordered">
                                    <tr>
                                        <th width="40%" class="bg-light">Faculty Name</th>
                                        <td><asp:Literal ID="litFacultyName" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <th class="bg-light">Department</th>
                                        <td><asp:Literal ID="litDept" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <th class="bg-light">Subject</th>
                                        <td><asp:Literal ID="litSubjectName" runat="server" /></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <table class="table table-bordered">
                                    <tr>
                                        <th width="40%" class="bg-light">Term</th>
                                        <td><asp:Literal ID="litTerm" runat="server" /></td>
                                    </tr>
                                    
                                </table>
                            </div>
                        </div>

                    </div>
                </div>

                <!-- Domain Summary -->
                <div class="card mb-4 print-section">
                    <div class="card-header bg-transparent py-3">
                        <h5 class="mb-0 fw-bold text-primary">Domain Performance Summary</h5>
                    </div>
                    <div class="card-body">
                       <asp:GridView ID="gvDomainSummary" runat="server" CssClass="table table-striped table-bordered" 
                            AutoGenerateColumns="False" OnRowDataBound="gvDomainSummary_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="DomainName" HeaderText="Evaluation Domain" ItemStyle-Width="50%" />
                                <asp:BoundField DataField="Weight" HeaderText="Weight" DataFormatString="{0}%" 
                                    ItemStyle-HorizontalAlign="Center" ItemStyle-Width="20%" />
                                <asp:TemplateField HeaderText="Weighted Score" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="30%">
                                    <ItemTemplate>
                                        <asp:Label ID="lblWeighted" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center py-4 text-muted">
                                    <i class="bi bi-bar-chart display-4 d-block mb-2"></i>
                                    <p>No domain data available for the selected evaluation.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        
                        <div class="row mt-3">
                            <div class="col-md-6 offset-md-6">
                                <div class="d-flex justify-content-between p-2 border-top">
                                    <strong>Overall Weighted Average:</strong>
                                    <span class="fw-bold text-primary"><asp:Literal ID="litWeightedAverage" runat="server" Text="0.00%" /></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Question Breakdown -->
                <div class="card mb-4 print-section">
                    <div class="card-header bg-transparent py-3">
                        <h5 class="mb-0 fw-bold text-primary">Question Performance Breakdown</h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th width="80%">Question</th>
                                        <th width="20%">Avg Score</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptDomains" runat="server" OnItemDataBound="rptDomains_ItemDataBound">
                                        <ItemTemplate>
                                            <tr class="domain-header-row">
                                                <td colspan="2" class="fw-bold py-2">
                                                    <i class="bi bi-collection me-2"></i>
                                                    <%# Eval("DomainName") %>
                                                </td>
                                            </tr>
                                            <asp:Repeater ID="rptDomainQuestions" runat="server">
                                                <ItemTemplate>
                                                    <tr>
                                                        <td class="ps-4"><%# Eval("QuestionText") %></td>
                                                        <td class="text-center fw-bold"><%# Eval("AverageScore", "{0:N2}") %>/5.0</td>
                                                    </tr>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>

                        <asp:Panel ID="pnlNoQuestions" runat="server" Visible="False" class="text-center py-4 text-muted">
                            <i class="bi bi-list-check display-4 d-block mb-2"></i>
                            <p>No question data available for the selected evaluation.</p>
                        </asp:Panel>
                    </div>
                </div>
<!-- Student Feedback Comments - Print Optimized -->
<div class="card mb-4 print-section">
    <div class="card-header bg-transparent py-3">
        <h5 class="mb-0 fw-bold text-primary">
            <i class="bi bi-chat-text me-2"></i>Student Feedback Summary
        </h5>
        <p class="text-muted mb-0 mt-1">Anonymous student comments grouped by category</p>
    </div>
    <div class="card-body p-0">
        
        <!-- Strengths Section -->
        <asp:Panel ID="pnlStrengths" runat="server" Visible="false" class="comment-section compact-comment">
            <div class="section-header bg-light border-bottom px-3 py-2">
                <h5 class="mb-0 fw-bold text-dark">Strengths</h5>
            </div>
            <div class="section-body px-3 py-2">
                <asp:Repeater ID="rptStrengths" runat="server">
                    <ItemTemplate>
                        <div class="comment-item mb-2 pb-2 border-bottom">
                            <div class="comment-content">
                                <span class="comment-text">"<%# Container.DataItem %>"</span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <!-- Weaknesses Section -->
        <asp:Panel ID="pnlWeaknesses" runat="server" Visible="false" class="comment-section compact-comment">
            <div class="section-header bg-light border-bottom px-3 py-2">
                <h5 class="mb-0 fw-bold text-dark">Areas for Improvement</h5>
            </div>
            <div class="section-body px-3 py-2">
                <asp:Repeater ID="rptWeaknesses" runat="server">
                    <ItemTemplate>
                        <div class="comment-item mb-2 pb-2 border-bottom">
                            <div class="comment-content">
                                <span class="comment-text">"<%# Container.DataItem %>"</span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <!-- Additional Comments Section -->
        <asp:Panel ID="pnlAdditionalMessages" runat="server" Visible="false" class="comment-section compact-comment">
            <div class="section-header bg-light border-bottom px-3 py-2">
                <h5 class="mb-0 fw-bold text-dark">Additional Comments</h5>
            </div>
            <div class="section-body px-3 py-2">
                <asp:Repeater ID="rptAdditionalMessages" runat="server">
                    <ItemTemplate>
                        <div class="comment-item mb-2 pb-2 border-bottom">
                            <div class="comment-content">
                                <span class="comment-text">"<%# Container.DataItem %>"</span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <!-- No Comments Message -->
        <asp:Panel ID="pnlNoComments" runat="server" Visible="false" class="text-center py-5">
            <i class="bi bi-chat-square-text display-4 text-muted d-block mb-3"></i>
            <h5 class="text-muted">No Student Comments Available</h5>
            <p class="text-muted">There are no student comments for this evaluation.</p>
        </asp:Panel>
    </div>
</div>
            </asp:Panel>
        </div>
    </form>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            initializeSidebar();
            initializeCycleAutocomplete();
            initializeEventListeners();
            updateVisibleCount();
        });

        function initializeSidebar() {
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');
            const desktopToggler = document.getElementById('sidebarToggler');
            const mobileToggler = document.getElementById('mobileSidebarToggler');
            const mainContent = document.querySelector('.content');

            // Load saved state
            const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';

            if (isCollapsed) {
                sidebar.classList.add('collapsed');
                if (mainContent) {
                    mainContent.style.marginLeft = '80px';
                }
                updateTogglerIcon(true);
            }

            // Desktop sidebar toggler
            if (desktopToggler) {
                desktopToggler.addEventListener('click', function (e) {
                    e.preventDefault();
                    toggleSidebar();
                });
            }

            // Mobile sidebar toggler
            if (mobileToggler) {
                mobileToggler.addEventListener('click', function (e) {
                    e.preventDefault();
                    sidebar.classList.toggle('mobile-open');
                    sidebarOverlay.classList.toggle('show');
                    document.body.style.overflow = sidebar.classList.contains('mobile-open') ? 'hidden' : '';
                });
            }

            // Overlay click to close mobile sidebar
            if (sidebarOverlay) {
                sidebarOverlay.addEventListener('click', function () {
                    sidebar.classList.remove('mobile-open');
                    sidebarOverlay.classList.remove('show');
                    document.body.style.overflow = '';
                });
            }

            // Close mobile sidebar on window resize
            window.addEventListener('resize', function () {
                if (window.innerWidth > 992) {
                    sidebar.classList.remove('mobile-open');
                    sidebarOverlay.classList.remove('show');
                    document.body.style.overflow = '';
                }
            });
        }

        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.querySelector('.content');

            sidebar.classList.toggle('collapsed');

            const isCollapsed = sidebar.classList.contains('collapsed');

            // Update main content margin
            if (mainContent) {
                mainContent.style.marginLeft = isCollapsed ? '80px' : '250px';
            }

            // Update icon and save state
            updateTogglerIcon(isCollapsed);
            localStorage.setItem('sidebarCollapsed', isCollapsed.toString());
        }

        function updateTogglerIcon(isCollapsed) {
            const toggler = document.getElementById('sidebarToggler');
            if (toggler) {
                toggler.innerHTML = isCollapsed ?
                    '<i class="bi bi-arrow-right-circle"></i>' :
                    '<i class="bi bi-arrow-left-circle"></i>';
            }
        }

        function initializeCycleAutocomplete() {
            // Get the server control ID for the cycle textbox
            const cycleTextBox = document.getElementById('<%= txtFilterCycle.ClientID %>');

            if (cycleTextBox) {
                $.ajax({
                    type: "POST",
                    url: "Prints.aspx/GetCycleNames",
                    data: JSON.stringify({}),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data.d && data.d.length > 0) {
                            $(cycleTextBox).autocomplete({
                                source: data.d,
                                minLength: 1,
                                select: function (event, ui) {
                                    $(this).val(ui.item.value);
                                    return false;
                                }
                            });
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error("Error loading cycle names: " + error);
                    }
                });
            }
        }

        function initializeEventListeners() {
            // Add event listeners for subject cards
            $(document).on('click', '.subject-card', function () {
                const subjectID = $(this).data('subject-id');
                const subjectName = $(this).data('subject-name');
                selectSubject(subjectID, subjectName);
            });

            // Initialize subject card interactions
            $('.subject-card').hover(
                function () {
                    if (!$(this).hasClass('selected')) {
                        $(this).css('transform', 'translateY(-5px)');
                        $(this).addClass('shadow-sm');
                    }
                },
                function () {
                    if (!$(this).hasClass('selected')) {
                        $(this).css('transform', 'scale(1)');
                        $(this).removeClass('shadow-sm');
                    }
                }
            );

            // Add click event listener for better mobile support
            $('.subject-card').on('click touchstart', function (e) {
                e.preventDefault();
                const subjectID = $(this).data('subject-id');
                const subjectName = $(this).data('subject-name');
                selectSubject(subjectID, subjectName);
            });

            // Prevent double-tap zoom on mobile
            $('.subject-card').on('touchend', function (e) {
                e.preventDefault();
                $(this).click();
            });
        }

        function selectSubject(subjectID, subjectName) {
            // Set hidden field values
            $('#<%= hfSelectedSubjectID.ClientID %>').val(subjectID);
           $('#<%= hfSelectedSubjectName.ClientID %>').val(subjectName);

           // Add visual feedback
           $('.subject-card').removeClass('selected shadow-lg');
           $('.subject-card').css({
               'transform': 'scale(1)',
               'border-color': '#e3e6f0'
           });

           // Find and highlight the selected card
           const selectedCard = $(`.subject-card[data-subject-id="${subjectID}"]`);
           if (selectedCard.length > 0) {
               selectedCard.addClass('selected shadow-lg');
               selectedCard.css({
                   'transform': 'scale(1.02)',
                   'border-color': '#1a3a8f'
               });

               // Update the subject name display immediately
               if (subjectID === 'all') {
                   $('.subject-name-display').text('All Subjects (Weighted Average)');
               } else {
                   $('.subject-name-display').text(subjectName);
               }
           }

           // Show loading state
           showLoadingState(selectedCard);

           // Trigger report generation after a brief delay for visual feedback
           setTimeout(function () {
               generateSubjectReport();
           }, 300);
       }

        function selectAllSubjects() {
            selectSubject('all', 'All Subjects');
        }

        function showLoadingState(selectedCard) {
            if (selectedCard.length > 0) {
                // Remove any existing loading indicators
                selectedCard.find('.loading-indicator').remove();

                // Add loading indicator
                selectedCard.append('<div class="loading-indicator text-center mt-2"><div class="spinner-border spinner-border-sm text-primary" role="status"></div> Loading report...</div>');
            }
        }

        function generateSubjectReport() {
            const subjectID = $('#<%= hfSelectedSubjectID.ClientID %>').val();
    const subjectName = $('#<%= hfSelectedSubjectName.ClientID %>').val();

    console.log('Generating report for:', subjectID, subjectName);

    if (subjectID) {
        // Trigger the hidden button click
        const hiddenButton = document.getElementById('<%= btnGenerateReportHidden.ClientID %>');
                if (hiddenButton) {
                    hiddenButton.click();
                } else {
                    console.error('Hidden button not found');
                    // Fallback: show error message
                    alert('Error: Could not generate report. Please try again.');
                }
            } else {
                console.error('No subject ID selected');
                alert('Please select a subject first.');
            }
        }

        function updateVisibleCount(count) {
            const badge = document.getElementById('visibleCountBadge');
            const noEvalsPanel = document.getElementById('<%= pnlNoEvaluations.ClientID %>');

            if (badge) {
                badge.textContent = count || '0';
            }

            if (noEvalsPanel) {
                noEvalsPanel.style.display = (count === 0 || count === '0') ? 'block' : 'none';
            }
        }

        // Client-side filtering for better responsiveness
        function filterEvaluations() {
            const facultyFilter = $('#<%= txtSearchFaculty.ClientID %>').val().toLowerCase();
          const departmentFilter = $('#<%= ddlFilterDepartment.ClientID %>').val();
          const cycleFilter = $('#<%= txtFilterCycle.ClientID %>').val().toLowerCase();

    let visibleCount = 0;

    $('.faculty-row').each(function () {
        const facultyName = $(this).data('faculty').toLowerCase();
        const departmentID = $(this).data('department-id').toString();
        const cycle = $(this).data('cycle').toLowerCase();
        const term = $(this).data('term').toLowerCase();

        const facultyMatch = facultyName.includes(facultyFilter);
        const departmentMatch = !departmentFilter || departmentID === departmentFilter;
        const cycleMatch = !cycleFilter || 
            cycle.includes(cycleFilter) || 
            term.toLowerCase().includes(cycleFilter);

        if (facultyMatch && departmentMatch && cycleMatch) {
            $(this).show();
            visibleCount++;
        } else {
            $(this).hide();
        }
    });

    updateVisibleCount(visibleCount);
}

function initializeRealTimeFiltering() {
    $('#<%= txtSearchFaculty.ClientID %>').on('input', debounceFilter);
    $('#<%= ddlFilterDepartment.ClientID %>').on('change', debounceFilter);
    $('#<%= txtFilterCycle.ClientID %>').on('input', debounceFilter);
}

        function clearFilters() {
            $('#<%= txtSearchFaculty.ClientID %>').val('');
    $('#<%= ddlFilterDepartment.ClientID %>').val('');
    $('#<%= txtFilterCycle.ClientID %>').val('');
    
    // Trigger the server-side filter to reload latest results
    __doPostBack('<%= btnApplyFilters.ClientID %>', '');
}

function optimizeForPrint() {
    // Add compact class to comments for print
    document.querySelectorAll('.section-body').forEach(section => {
        section.classList.add('compact-comment');
    });

    // Remove any interactive elements
    document.querySelectorAll('.btn, .no-print').forEach(el => {
        el.style.display = 'none';
    });

    // Ensure proper print layout
    document.body.classList.add('printing');
}

function restoreAfterPrint() {
    // Restore elements after print
    document.querySelectorAll('.btn, .no-print').forEach(el => {
        el.style.display = '';
    });

    // Remove compact class
    document.querySelectorAll('.section-body').forEach(section => {
        section.classList.remove('compact-comment');
    });

    document.body.classList.remove('printing');
}

// Enhanced print handling
window.addEventListener('beforeprint', optimizeForPrint);
window.addEventListener('afterprint', restoreAfterPrint);

// Initialize everything when DOM is ready
$(document).ready(function () {
    // Initialize real-time filtering
    initializeRealTimeFiltering();
    
    // Apply initial filter
    filterEvaluations();
    
    // Add keyboard shortcuts
    $(document).keydown(function(e) {
        // Ctrl + P for print
        if (e.ctrlKey && e.key === 'p') {
            e.preventDefault();
            window.print();
        }
        
        // Escape key to clear filters
        if (e.key === 'Escape') {
            clearFilters();
        }
    });
    
    // Add smooth scrolling for better UX
    $('a[href^="#"]').on('click', function(e) {
        e.preventDefault();
        const target = $(this.getAttribute('href'));
        if (target.length) {
            $('html, body').animate({
                scrollTop: target.offset().top - 20
            }, 500);
        }
    });
});

// Error handling for AJAX calls
$(document).ajaxError(function(event, jqxhr, settings, thrownError) {
    console.error('AJAX Error:', {
        url: settings.url,
        status: jqxhr.status,
        error: thrownError
    });
    
    // Show user-friendly error message for critical failures
    if (settings.url.includes('GetCycleNames')) {
        console.warn('Cycle autocomplete data load failed, but the page will still function');
    }
});

// Performance optimization: Debounce filter input
let filterTimeout;
function debounceFilter() {
    clearTimeout(filterTimeout);
    filterTimeout = setTimeout(filterEvaluations, 300);
}

// Update event listeners to use debounced filtering
function initializeOptimizedFiltering() {
    $('#<%= txtSearchFaculty.ClientID %>').on('input', debounceFilter);
    $('#<%= txtFilterCycle.ClientID %>').on('input', debounceFilter);
    $('#<%= ddlFilterDepartment.ClientID %>').on('change', filterEvaluations);

        }

        // Mobile-specific enhancements
        function initializeMobileEnhancements() {
            if (window.innerWidth <= 768) {
                // Add touch-friendly styles
                $('.btn').addClass('btn-mobile');
                $('.subject-card').addClass('mobile-touch-target');

                // Prevent zoom on double-tap
                document.addEventListener('touchstart', function (e) {
                    if (e.touches.length > 1) {
                        e.preventDefault();
                    }
                }, { passive: false });
            }
        }

        // Initialize mobile enhancements
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializeMobileEnhancements);
        } else {
            initializeMobileEnhancements();
        }

        // Export functions for global access (if needed)
        window.PrintsJS = {
            filterEvaluations,
            clearFilters,
            selectSubject,
            selectAllSubjects,
            generateSubjectReport,
            optimizeForPrint
        };
        function optimizePrintLayout() {
            // Remove circular styling from print logo
            const printLogoContainer = document.querySelector('.print-logo-section');
            const printLogo = document.querySelector('.print-logo-section img');

            if (printLogoContainer) {
                printLogoContainer.style.border = 'none';
                printLogoContainer.style.background = 'transparent';
            }

            if (printLogo) {
                printLogo.style.border = 'none';
                printLogo.style.borderRadius = '0';
                printLogo.style.boxShadow = 'none';
                printLogo.style.maxWidth = '80px';
                printLogo.style.maxHeight = '80px';
            }

            // Apply consistent font sizes for print
            document.querySelectorAll('.comment-text, .table, .table th, .table td').forEach(el => {
                el.style.fontSize = '9pt';
                el.style.lineHeight = '1.3';
            });

            // Ensure domain headers have consistent font
            document.querySelectorAll('.domain-header-row td').forEach(el => {
                el.style.fontSize = '9pt';
                el.style.fontWeight = 'bold';
            });

            // Remove any colored backgrounds for print
            document.querySelectorAll('.bg-success, .bg-warning, .bg-info').forEach(el => {
                el.style.backgroundColor = '#f8f9fa !important';
                el.style.color = '#000 !important';
            });
        }

        window.addEventListener('beforeprint', optimizePrintLayout);
        // Function to update sidebar badges
        function updateSidebarBadges() {
            $.ajax({
                type: "POST",
                url: "Prints.aspx/GetSidebarBadgeCounts",
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

