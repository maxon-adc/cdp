﻿using Core.Entities;
using DAL.Repositories.Interfaces;

namespace DAL.UnitOfWork.Interfaces
{
    public interface IRepositoryWrapper
	{
		IRepository<Route> RouteRepository { get; }

		IRepository<Warehouse> WarehouseRepository { get; }
	}
}
