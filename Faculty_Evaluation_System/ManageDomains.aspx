<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ManageDomains.aspx.vb" Inherits="Faculty_Evaluation_System.ManageDomains" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <title>Manage Evaluation Domains - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" />
    <style>
        /* Your existing CSS styles remain the same */
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
        }
        
        body { 
            background-color: #f8f9fc; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
        }
        
        .card { 
            border: none; 
            border-radius: 0.35rem; 
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58,59,69,.15); 
            margin-bottom: 1.5rem; 
            transition: all 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }
        
        .card-header { 
            background-color: #f8f9fc; 
            border-bottom: 1px solid #e3e6f0;
            padding: 0.75rem 1.25rem;
            font-weight: 700;
            color: var(--primary);
        }
        
        .weight-input { 
            max-width: 100px; 
        }
        
        .total-weight { 
            font-weight: bold; 
            color: var(--primary); 
            background: #f8f9fc; 
            padding: 8px 15px; 
            border-radius: 0.35rem; 
            border: 1px solid #e3e6f0; 
            display: inline-block;
        }
        
        .page-title {
            color: var(--primary);
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.5rem;
        }
        
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }
        
        .btn-secondary {
            background-color: var(--secondary);
            border-color: var(--secondary);
        }
        
        .btn-outline-secondary {
            border-color: var(--secondary);
            color: var(--secondary);
        }
        
        .btn-outline-secondary:hover {
            background-color: var(--secondary);
            border-color: var(--secondary);
            color: white;
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
        
        .btn-success {
            background-color: var(--success);
            border-color: var(--success);
        }
        
        .btn-danger {
            background-color: var(--danger);
            border-color: var(--danger);
        }
        
        .badge.bg-primary {
            background-color: var(--primary) !important;
        }
        
        .badge.bg-info {
            background-color: var(--info) !important;
        }
        
        .table {
            border-radius: 0.35rem;
            overflow: hidden;
        }
        
        .table th {
            background-color: #f8f9fc;
            border-top: none;
            font-weight: 700;
            color: var(--dark);
            padding: 0.75rem;
        }
        
        .table-striped tbody tr:nth-of-type(odd) {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .table-hover tbody tr:hover {
            background-color: rgba(26, 58, 143, 0.05);
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
        }
        
        .alert {
            border-radius: 0.35rem;
            border: none;
            padding: 1rem 1.25rem;
        }
        
        .text-primary {
            color: var(--primary) !important;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .animate-card {
            animation: fadeInUp 0.6s ease-out;
        }
        
        @media (max-width: 768px) {
            .container {
                padding-left: 1rem;
                padding-right: 1rem;
            }
            
            .card-body {
                padding: 1rem;
            }
            
            .weight-input {
                max-width: 100%;
            }
            
            .btn-sm {
                padding: 0.25rem 0.5rem;
                font-size: 0.75rem;
            }
            
            .card-body .row.g-3 .col-md-5,
            .card-body .row.g-3 .col-md-3,
            .card-body .row.g-3 .col-md-2 {
                width: 100%;
                margin-bottom: 1rem;
            }
            
            .card-body .row.g-3 .col-md-2 .btn {
                width: 100%;
            }
        }
        
        @media (max-width: 576px) {
            .d-flex.justify-content-between.align-items-center.mb-4 {
                flex-direction: column;
                align-items: flex-start !important;
            }
            
            .d-flex.justify-content-between.align-items-center.mb-4 .btn {
                margin-top: 0.5rem;
                align-self: flex-end;
            }
            
            .table-responsive {
                border: 1px solid #dee2e6;
                border-radius: 0.375rem;
            }
            
            .card-header.d-flex.justify-content-between.align-items-center {
                flex-direction: column;
                align-items: flex-start !important;
            }
            
            .card-header.d-flex.justify-content-between.align-items-center .badge {
                margin-top: 0.5rem;
            }
        }
        
        /* Disabled state styling */
        .form-control:disabled {
            background-color: #e9ecef;
            opacity: 1;
        }
        
        .btn:disabled {
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container py-4">

            <!-- Alert -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert d-none mb-3" />

            <!-- Page Title -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="mb-0"><i class="bi bi-collection me-2"></i>Manage Evaluation Domains</h2>
                <a href="Questions.aspx" class="btn btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Back to Questions</a>
            </div>

            <!-- Add Domain -->
            <div class="card mb-4">
                <div class="card-header">
                    <i class="bi bi-plus-circle me-2 text-primary"></i>Add New Domain
                </div>
                <div class="card-body row g-3 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label fw-bold">Domain Name</label>
                        <asp:TextBox ID="txtDomain" runat="server" CssClass="form-control" placeholder="Enter domain name"></asp:TextBox>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Weight (%)</label>
                        <asp:TextBox ID="txtWeight" runat="server" CssClass="form-control weight-input" TextMode="Number" Text="20" min="1" max="100"></asp:TextBox>
                    </div>
                    <div class="col-md-2">
                        <asp:Button ID="btnAddDomain" runat="server" Text="Add Domain" CssClass="btn btn-primary w-100" OnClick="btnAddDomain_Click" />
                    </div>
                    <div class="col-12 mt-3">
                        <span class="total-weight">Total Weight: <asp:Label ID="lblTotalWeight" runat="server" Text="0" />%</span>
                    </div>
                </div>
            </div>

            <!-- Domain List -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 text-primary"><i class="bi bi-list-ul me-2"></i>Domains List</h5>
                    <span class="badge bg-primary"><asp:Label ID="lblDomainCount" runat="server" Text="0" /> Domains</span>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvDomains" runat="server" CssClass="table table-striped table-bordered table-hover"
                        AutoGenerateColumns="False" DataKeyNames="DomainID"
                        AllowPaging="true" PageSize="10"
                        OnPageIndexChanging="gvDomains_PageIndexChanging"
                        OnRowEditing="gvDomains_RowEditing"
                        OnRowCancelingEdit="gvDomains_RowCancelingEdit"
                        OnRowUpdating="gvDomains_RowUpdating"
                        OnRowDeleting="gvDomains_RowDeleting"
                        OnRowDataBound="gvDomains_RowDataBound">

                        <Columns>
                            <asp:BoundField DataField="DomainID" HeaderText="ID" ReadOnly="true" Visible="False" />

                            <asp:TemplateField HeaderText="Domain Name">
                                <ItemTemplate><%# Eval("DomainName") %></ItemTemplate>
                                <EditItemTemplate>
                                    <asp:TextBox ID="txtEditDomainName" runat="server" CssClass="form-control" Text='<%# Bind("DomainName") %>' />
                                </EditItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Weight (%)">
                                <ItemTemplate><span class="badge bg-info"><%# Eval("Weight") %>%</span></ItemTemplate>
                                <EditItemTemplate>
                                    <asp:TextBox ID="txtEditWeight" runat="server" CssClass="form-control weight-input" Text='<%# Bind("Weight") %>' TextMode="Number" min="1" max="100" />
                                </EditItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn btn-sm btn-warning me-1"><i class="bi bi-pencil"></i> Edit</asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-danger" OnClientClick="return confirm('Delete this domain?');"><i class="bi bi-trash"></i> Delete</asp:LinkButton>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="btn btn-sm btn-success me-1"><i class="bi bi-check"></i> Update</asp:LinkButton>
                                    <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="btn btn-sm btn-secondary"><i class="bi bi-x"></i> Cancel</asp:LinkButton>
                                </EditItemTemplate>
                            </asp:TemplateField>
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="text-center py-3 text-muted">
                                <i class="bi bi-collection display-6 d-block mb-2"></i>
                                No domains found.
                            </div>
                        </EmptyDataTemplate>

                        <PagerStyle CssClass="pagination" />
                        <PagerSettings Mode="NumericFirstLast" />
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>